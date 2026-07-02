#!/bin/bash

# "Strict mode"
set -eu -o pipefail

echo "Building test container…"
TEST_IMG=$(docker build -q --target test .)

echo "Running tests in container…"
docker run --rm "${TEST_IMG}"

echo "Checking that app container builds successfully…"
APP_IMG=$(docker build -q .)

echo "Successfully built app container with digest $APP_IMG"
