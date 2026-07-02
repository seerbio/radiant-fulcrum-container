#!/bin/bash

# "Strict mode"
set -eu -o pipefail

CONTAINER=${CONTAINER:-seer/radiant-fulcrum}
TAG_MATCH_CONTAINER=${TAG_MATCH_CONTAINER:-$CONTAINER}
REPOSITORY=${REPOSITORY:-docker.io}
TAG_SUFFIX=${TAG_SUFFIX:?TAG_SUFFIX is required}
CACHE_SCOPE=${CACHE_SCOPE:-}

GIT_TAG_VERSION=$(git tag --points-at | grep -Po "^($TAG_MATCH_CONTAINER/)?v?\K\d+\.\d+\.\d+.*$" | sort -Vr | head -n 1 || true)
VERSION=${VERSION:-$GIT_TAG_VERSION}

if [[ -z "$VERSION" ]]; then
  echo "Could not determine VERSION from env or git tags matching '$TAG_MATCH_CONTAINER'" >&2
  exit 1
fi

TAGS=("${VERSION}${TAG_SUFFIX}")
if [[ -n "${1:-}" ]]; then
  read -r -a EXTRA_TAGS <<< "${1}"
  TAGS+=("${EXTRA_TAGS[@]}")
fi

docker_build_args=(
  build
  --load
  --target app
)

if [[ -n "$CACHE_SCOPE" ]]; then
  docker_build_args+=(
    --cache-from "type=gha,scope=${CACHE_SCOPE}"
    --cache-to "type=gha,scope=${CACHE_SCOPE},mode=max"
  )
fi

for TAG in "${TAGS[@]}"; do
  docker_build_args+=(-t "${REPOSITORY}/${CONTAINER}:${TAG}")
done

echo "Building container image(s): ${TAGS[*]}"
docker buildx "${docker_build_args[@]}" .

for TAG in "${TAGS[@]}"; do
  echo "Pushing ${REPOSITORY}/${CONTAINER}:${TAG}"
  docker push "${REPOSITORY}/${CONTAINER}:${TAG}"
done
