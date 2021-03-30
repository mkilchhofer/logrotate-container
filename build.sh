#!/bin/bash
set -euo pipefail
TRAVIS_BRANCH_STRIPPED=${TRAVIS_BRANCH/[^a-zA-Z0-9]/_}

# Build docker image
docker build --no-cache -t myimage .

# Extract version information
LOGROTATE_VERSION_FULL=$(docker run --rm -it myimage /usr/sbin/logrotate --version | head -n 1 | awk '{print $2}' | sed -e 's/\r//g')
LOGROTATE_VERSION_MAJOR=$(echo "${LOGROTATE_VERSION_FULL}" | awk -F '.' '{print $1}')
LOGROTATE_VERSION_MINOR=$(echo "${LOGROTATE_VERSION_FULL}" | awk -F '.' '{print $2}')

# Login into docker hub
echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin

# Handle main branch different
if [ "${TRAVIS_BRANCH_STRIPPED}" == "main" ]; then
  IMAGE_EXACT_VERSION="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${LOGROTATE_VERSION_FULL}-build${TRAVIS_BUILD_NUMBER}"
  IMAGE_LATEST="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
  IMAGE_MAJOR="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${LOGROTATE_VERSION_MAJOR}"
  IMAGE_MINOR="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${LOGROTATE_VERSION_MAJOR}.${LOGROTATE_VERSION_MINOR}"

  docker tag myimage "${IMAGE_EXACT_VERSION}"
  docker push "${IMAGE_EXACT_VERSION}"

  docker tag myimage "${IMAGE_LATEST}"
  docker push "${IMAGE_LATEST}"

  docker tag myimage "${IMAGE_MAJOR}"
  docker push "${IMAGE_MAJOR}"

  docker tag myimage "${IMAGE_MINOR}"
  docker push "${IMAGE_MINOR}"

else
  IMAGE_NON_MAIN="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TRAVIS_BRANCH_STRIPPED}"

  docker tag myimage "${IMAGE_NON_MAIN}"
  docker push "${IMAGE_NON_MAIN}"
fi
