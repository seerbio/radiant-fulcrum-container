#!/bin/bash

# "Strict mode"
set -eu -o pipefail

echo "Building test container…"
docker build --target test \
  --build-arg AWS_DEFAULT_REGION \
  --build-arg AWS_ACCESS_KEY_ID \
  --build-arg AWS_SECRET_ACCESS_KEY \
  --build-arg AWS_SESSION_TOKEN \
  .
TEST_IMG=$( \
    docker build -q --target test \
    --build-arg AWS_DEFAULT_REGION \
    --build-arg AWS_ACCESS_KEY_ID \
    --build-arg AWS_SECRET_ACCESS_KEY \
    --build-arg AWS_SESSION_TOKEN \
    . \
  )

echo "Running tests in container…"
docker run --rm \
  -e AWS_DEFAULT_REGION \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN \
  "${TEST_IMG}"

echo "Checking that app container builds successfully…"
docker build \
  --build-arg AWS_DEFAULT_REGION \
  --build-arg AWS_ACCESS_KEY_ID \
  --build-arg AWS_SECRET_ACCESS_KEY \
  --build-arg AWS_SESSION_TOKEN \
  .
APP_IMG=$( \
    docker build -q \
    --build-arg AWS_DEFAULT_REGION \
    --build-arg AWS_ACCESS_KEY_ID \
    --build-arg AWS_SECRET_ACCESS_KEY \
    --build-arg AWS_SESSION_TOKEN \
    . \
  )

echo "Successfully built app container with digest $APP_IMG"
