#!/bin/bash

# "Strict mode"
set -eu -o pipefail

CONTAINER=${CONTAINER:-seer/radiant-fulcrum}
TAG_MATCH_CONTAINER=${TAG_MATCH_CONTAINER:-$CONTAINER}
REPOSITORY=${REPOSITORY:-docker.io}

GIT_TAG_VERSION=$(git tag --points-at | grep -Po "^($TAG_MATCH_CONTAINER/)?v?\K\d+\.\d+\.\d+.*$" | sort -Vr | head -n 1 || true)
VERSION=${VERSION:-$GIT_TAG_VERSION}

if [[ -z "$VERSION" ]]; then
  echo "Could not determine VERSION from env or git tags matching '$TAG_MATCH_CONTAINER'" >&2
  exit 1
fi

MAJVER=$(grep -Po '^.+?(?=\..+)' <<< "$VERSION") \
  || (echo "Could not parse major version from $VERSION" && exit 1)
MINVER=$(grep -Po '^.+?\..+?(?=\..+)' <<< "$VERSION") \
  || (echo "Could not parse minor version from $VERSION" && exit 1)

# Build and push a manifest with the semantic version.
echo "Building multi-arch manifest ${REPOSITORY}/${CONTAINER}:${VERSION}"
docker manifest create \
  "${REPOSITORY}/${CONTAINER}:${VERSION}" \
  "${REPOSITORY}/${CONTAINER}:${VERSION}-x86_64" \
  "${REPOSITORY}/${CONTAINER}:${VERSION}-aarch64"
docker manifest push --purge "${REPOSITORY}/${CONTAINER}:${VERSION}"

# Build/push manifest for minor/major versions
for TAG in \
  "${MINVER}" \
  "${MAJVER}" ;
do
  echo "Tagging ${REPOSITORY}/${CONTAINER}:${VERSION} as ${CONTAINER}:${TAG}"

  docker manifest create \
    "${REPOSITORY}/${CONTAINER}:${TAG}" \
    "${REPOSITORY}/${CONTAINER}:${VERSION}-x86_64" \
    "${REPOSITORY}/${CONTAINER}:${VERSION}-aarch64"
  docker manifest push --purge "${REPOSITORY}/${CONTAINER}:${TAG}"
done

# If an argument was given, treat it as a single string of space-separated additional tags.
for TAG in $(echo "${1:-}") ; do
  echo "Tagging ${REPOSITORY}/${CONTAINER}:${VERSION} as ${CONTAINER}:${TAG}"

  docker manifest create \
    "${REPOSITORY}/${CONTAINER}:${TAG}" \
    "${REPOSITORY}/${CONTAINER}:${VERSION}-x86_64" \
    "${REPOSITORY}/${CONTAINER}:${VERSION}-aarch64"
  docker manifest push --purge "${REPOSITORY}/${CONTAINER}:${TAG}"
done
