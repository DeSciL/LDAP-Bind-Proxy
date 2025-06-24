#!/bin/bash
REGISTRY=registry.ethz.ch/descil;
ORG=descil;
REPO=infra;
LABEL=ldap-proxy;
NS=;
# if NS is not set, set target without it
target=${REGISTRY}/${ORG}/${REPO}/${NS}-${LABEL};
if [ -z "$NS" ]; then
  target=${REGISTRY}/${ORG}/${REPO}/${LABEL};
  echo "No namespace set, using target: ${target}"
fi

# Get latest tag or create a new one
source tag_push.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Docker login to the specified registry
docker login ${target}

# Build the Docker image using the specified Dockerfile
docker build -t ${target}:${tag} -f Dockerfile . --network=host
if [ $? -ne 0 ]; then
  echo “~~~~ error: failed to build docker container ~~~~~”
fi

# Run the Docker container (in detached mode -d), mapping port 5000 on the host to port 80 on the container
# docker run -p 5000:80 ${target}:${tag}

# Push the built Docker image to the registry
docker push ${target}:${tag}

# Tag the image as 'latest'
docker tag ${target}:${tag} ${target}:latest

# Push the 'latest' tagged image to the registry
docker push ${target}:latest
