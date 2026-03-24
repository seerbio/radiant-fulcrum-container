################################################
#
# Base stage
#
# Here we set up common configuration and runtime dependencies
# that are shared between the build stage and final image.
#
################################################
ARG RADIANT_VERSION=718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/radiant-dia:latest
FROM $RADIANT_VERSION AS base

#
# Update and install python / Java.
#
# We use a single RUN statement to reduce the number of image layers
# created by docker, which reduces overall image size.
#
# After package installation, we remove any unnecessary packages
# and run `apt-get clean` to remove any downloaded package archives.
#
ARG PYTHON=python3.10
ARG JAVA=default-jre-headless
RUN apt-get update \
    && apt-get install --no-install-recommends -y "$PYTHON" python-is-python3 "$JAVA" \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV FULCRUM_VIRTUAL_ENV=/usr/local/venv

################################################
#
# Build stage
#
# Here we install development/build tools and fetch dependencies.
#
################################################
FROM base AS build

ARG PYTHON=python3.10

# Install `pip` and `awscli` so we can fetch Python dependencies.
# Re-run `apt-get update` in case the previous update was cached
# and is now out of date.
# Using `--no-cache-dir` avoids bloating the image with downloaded
# whl files.
RUN apt-get update \
    && apt-get install --no-install-recommends -y python3-pip "${PYTHON}-venv" \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir 'awscli>=1.18.83'

# Install Python deps from CodeArtifact

COPY /requirements.txt /tmp/

# These need to be set in your environment as they are needed for the image build.
# They will not be available to the container at runtime.
#
# Leaving this to the latest possible point in the Dockerfile as these change on a regular
# basis. This allows Docker to cache previous layers, reducing build time.

ARG AWS_DEFAULT_REGION=us-west-2
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN

# Get login credentials to pull artifacts from our AWS CodeArtifact
# and run `pip` to fetch dependencies into a virtual env.
# Also unset the index-url for CodeArtifact to avoid leaking credentials into the `test` stage.

RUN aws codeartifact login --tool pip --repository seer_ds --domain seer --domain-owner 718843040700 \
    && python -m venv "${FULCRUM_VIRTUAL_ENV}" \
    && pip uninstall --no-input --yes --no-cache-dir awscli \
    && "${FULCRUM_VIRTUAL_ENV}/bin/python" -m pip install --no-input --no-cache-dir -r /tmp/requirements.txt \
    && pip config unset global.index-url

################################################
#
# Test stage
#
# Here we add test dependencies to the build container
# and define the command that will run the tests.
#
################################################
FROM build AS test

ENV PATH="${FULCRUM_VIRTUAL_ENV}/bin:$PATH"

#
# Install pytest, pylint
#
RUN pip install --no-input --no-cache-dir pytest #pytest-cov pylint

#
# Copy tests from build context.
#
COPY /tests /tests

#
# This entrypoint allows running tests (with coverage)
# by building with `--target test` and then running the
# resulting container. See README.md for more.
#
# Must run from `/` to ensure `tests/` can be located
# as a relative path (used for test data).
#
WORKDIR /
CMD ["pytest"]

################################################
#
# App stage
#
# Here we build the final container used to run the app in production.
#
################################################
FROM base AS app

#
# Set labels
#
LABEL author="Seer, Inc."
LABEL description="Radiant DIA and Fulcrum Pipeline, packaged for local execution"

#
# Copy virtual env from build stage
#
COPY --from=build ${FULCRUM_VIRTUAL_ENV} ${FULCRUM_VIRTUAL_ENV}
COPY README.md /
COPY Dockerfile /
COPY /examples/ /examples/

ENV PATH="${FULCRUM_VIRTUAL_ENV}/bin:$PATH:/usr/local/bin/radiant/"

# Scripts mostly do work in the current directory, so give them a dedicated space
WORKDIR /work

# By default we inherit the entrypoint/command of the base container,
# which sets the entrypoint to the Radiant executable, so any command
# is interprested as Radiant arguments.
# Instead, we'd like to allow users to either run Fulcrum, or an interactive
# environment. Here we just restore a default(ish) entrypoint to permit running
# arbitrary shell commands in the container with `docker run`.
ENTRYPOINT []

# By default, launch an interactive shell.
# Consider changing to a Fulcrum command.
CMD ["bash"]
