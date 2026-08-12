#!/usr/bin/env bash
#
# Build the linux/amd64 CRUD Service image, push it to ECR and tag the git repo.
#
# Usage:
#   ./build-to-ecr.sh <tag> [options]
#
# Options:
#   --latest        also push the `latest` tag to ECR
#   --allow-dirty   build even if the git working tree is dirty (no git tag is created)
#   --no-git-tag    skip creating/pushing the git tag
#   -y, --yes       do not ask for confirmation
#
# Environment overrides:
#   AWS_REGION (eu-west-3), AWS_ACCOUNT_ID (972096737302),
#   ECR_REPOSITORY (carol/crud-service), DOCKER_TARGET (crud-service-with-encryption),
#   GIT_REMOTE (origin), AWS_PROFILE (passed through to the aws cli)

set -euo pipefail

AWS_REGION="${AWS_REGION:-eu-west-3}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-972096737302}"
ECR_REPOSITORY="${ECR_REPOSITORY:-carol/crud-service}"
DOCKER_TARGET="${DOCKER_TARGET:-crud-service-with-encryption}"
PLATFORM="linux/amd64"
GIT_REMOTE="${GIT_REMOTE:-origin}"

PUSH_LATEST=false
ALLOW_DIRTY=false
CREATE_GIT_TAG=true
ASSUME_YES=false
TAG=""

die() { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --latest)      PUSH_LATEST=true ;;
    --allow-dirty) ALLOW_DIRTY=true ;;
    --no-git-tag)  CREATE_GIT_TAG=false ;;
    -y|--yes)      ASSUME_YES=true ;;
    -h|--help)     awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"; exit 0 ;;
    -*)            die "unknown option: $1" ;;
    *)
      [[ -n "$TAG" ]] && die "unexpected argument: $1"
      TAG="$1"
      ;;
  esac
  shift
done

[[ -n "$TAG" ]] || die "missing tag name. Usage: $0 <tag> [--latest] [--allow-dirty] [--no-git-tag] [-y]"

# A valid docker tag is also a valid git tag name, so validate against the stricter one.
[[ "$TAG" =~ ^[A-Za-z0-9_][A-Za-z0-9._-]{0,127}$ ]] \
  || die "'$TAG' is not a valid docker image tag"
git check-ref-format "refs/tags/$TAG" || die "'$TAG' is not a valid git tag name"

for cmd in docker aws git; do
  command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is not installed or not in PATH"
done

cd "$(dirname "$0")"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"

REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE="${REGISTRY}/${ECR_REPOSITORY}"
COMMIT_SHA="$(git rev-parse HEAD)"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# --- pre-flight checks -------------------------------------------------------

if [[ -n "$(git status --porcelain)" ]]; then
  if [[ "$ALLOW_DIRTY" == true ]]; then
    echo "warning: working tree is dirty, the git tag will NOT be created" >&2
    CREATE_GIT_TAG=false
  else
    die "working tree is dirty. Commit your changes or pass --allow-dirty"
  fi
fi

if [[ "$CREATE_GIT_TAG" == true ]]; then
  git rev-parse -q --verify "refs/tags/$TAG" >/dev/null \
    && die "git tag '$TAG' already exists locally"
  if git ls-remote --exit-code --tags "$GIT_REMOTE" "refs/tags/$TAG" >/dev/null 2>&1; then
    die "git tag '$TAG' already exists on remote '$GIT_REMOTE'"
  fi
fi

info "checking AWS credentials"
CALLER_ACCOUNT="$(aws sts get-caller-identity --query Account --output text)" \
  || die "unable to call AWS STS, check your credentials (AWS_PROFILE=${AWS_PROFILE:-<unset>})"
[[ "$CALLER_ACCOUNT" == "$AWS_ACCOUNT_ID" ]] \
  || die "authenticated on AWS account $CALLER_ACCOUNT but expected $AWS_ACCOUNT_ID"

aws ecr describe-repositories --region "$AWS_REGION" --repository-names "$ECR_REPOSITORY" >/dev/null \
  || die "ECR repository '$ECR_REPOSITORY' not found in $AWS_REGION"

if aws ecr describe-images --region "$AWS_REGION" --repository-name "$ECR_REPOSITORY" \
    --image-ids "imageTag=$TAG" >/dev/null 2>&1; then
  echo "warning: image tag '$TAG' already exists in ECR and will be overwritten" >&2
fi

cat <<EOF

  image      ${IMAGE}:${TAG}$([[ "$PUSH_LATEST" == true ]] && echo " (+ :latest)")
  platform   ${PLATFORM}
  target     ${DOCKER_TARGET}
  commit     ${COMMIT_SHA} (${BRANCH})
  git tag    $([[ "$CREATE_GIT_TAG" == true ]] && echo "${TAG} -> ${GIT_REMOTE}" || echo "skipped")

EOF

if [[ "$ASSUME_YES" != true && -t 0 ]]; then
  read -r -p "Proceed? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || die "aborted"
fi

# --- build -------------------------------------------------------------------

info "logging in to ${REGISTRY}"
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$REGISTRY"

info "building ${IMAGE}:${TAG} for ${PLATFORM}"
build_args=(
  --platform "$PLATFORM"
  --target "$DOCKER_TARGET"
  --build-arg "COMMIT_SHA=${COMMIT_SHA}"
  --provenance=false
  --tag "${IMAGE}:${TAG}"
)
[[ "$PUSH_LATEST" == true ]] && build_args+=(--tag "${IMAGE}:latest")
docker build "${build_args[@]}" .

# --- push --------------------------------------------------------------------

info "pushing ${IMAGE}:${TAG}"
docker push "${IMAGE}:${TAG}"
if [[ "$PUSH_LATEST" == true ]]; then
  info "pushing ${IMAGE}:latest"
  docker push "${IMAGE}:latest"
fi

# --- git tag -----------------------------------------------------------------

if [[ "$CREATE_GIT_TAG" == true ]]; then
  info "tagging ${COMMIT_SHA} as '${TAG}' and pushing to ${GIT_REMOTE}"
  git tag -a "$TAG" -m "Release ${TAG}"
  git push "$GIT_REMOTE" "refs/tags/${TAG}"
fi

DIGEST="$(aws ecr describe-images --region "$AWS_REGION" --repository-name "$ECR_REPOSITORY" \
  --image-ids "imageTag=$TAG" --query 'imageDetails[0].imageDigest' --output text 2>/dev/null || echo "unknown")"

cat <<EOF

Done.
  ${IMAGE}:${TAG}
  digest: ${DIGEST}

Deploy it by setting image_tag = "${TAG}" in infra/variables.tf (or -var image_tag=${TAG}).
EOF
