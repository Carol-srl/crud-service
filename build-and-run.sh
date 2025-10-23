# Build with secrets (expects secrets in ./secrets dir)
docker build --platform linux/amd64 -t engineeringcarol/crud-service . \
  --secret id=aws_access_key_id,src=./secrets/aws_access_key_id \
  --secret id=aws_secret_access_key,src=./secrets/aws_secret_access_key

# Run with Docker secrets mounted as files
# The bootstrap script will read secrets from /run/secrets

docker run --rm --name crud-service \
           --platform linux/amd64 \
           --env-file=build.env \
           --mount type=bind,source=$(pwd)/secrets,target=/run/secrets,readonly \
           --publish 3000:3000 \
           --network carol-cluster_default \
           engineeringcarol/crud-service:latest