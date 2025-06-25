#!/bin/bash
set -e

# S3 env vars
S3_USE_IAM_ROLE="${S3_USE_IAM_ROLE:-false}"
S3_REGION="${S3_REGION:-us-east-1}"
S3_BUCKET="${S3_BUCKET:-}"
S3_TARGET_DIR="/home/node/app/disk"

# Read secrets from Docker secrets if present
if [ -f /run/secrets/aws_access_key_id ]; then
  S3_ACCESS_KEY_ID=$(cat /run/secrets/aws_access_key_id)
fi
if [ -f /run/secrets/aws_secret_access_key ]; then
  S3_SECRET_ACCESS_KEY=$(cat /run/secrets/aws_secret_access_key)
fi

mkdir -p "$S3_TARGET_DIR/collections"
mkdir -p "$S3_TARGET_DIR/views"

if [ -z "$S3_BUCKET" ]; then
  echo "S3_BUCKET env var is required" >&2
  exit 1
fi

export AWS_DEFAULT_REGION="$S3_REGION"

if [ "$S3_USE_IAM_ROLE" = "true" ]; then
  echo "Using IAM role for AWS credentials"
else
  if [ -z "$S3_ACCESS_KEY_ID" ] || [ -z "$S3_SECRET_ACCESS_KEY" ]; then
    echo "S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY are required if not using IAM role" >&2
    exit 1
  fi
  export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$S3_SECRET_ACCESS_KEY"
fi

echo "Downloading files from s3://$S3_BUCKET to $S3_TARGET_DIR ..."
aws s3 sync "s3://$S3_BUCKET" "$S3_TARGET_DIR" --no-progress

echo "Running the original CMD..."

# Run the original CMD
./node_modules/.bin/lc39 ./index.js --port=${HTTP_PORT} --log-level=${LOG_LEVEL} --prefix=${SERVICE_PREFIX} --expose-metrics=${EXPOSE_METRICS} --enable-tracing=${ENABLE_TRACING}