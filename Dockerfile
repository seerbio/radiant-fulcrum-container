################################################
#
# Base stage
#
# Here we set up common configuration and runtime dependencies
# that are shared between the build stage and final image.
#
################################################
FROM ubuntu:22.04 AS base

#
# Set locales to UTF-8
#
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

#
# Set timezone
#
ENV TZ=US/Pacific
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG PYTHON=python3.10

#
# Update, upgrade, and install python.
#
# We use a single RUN statement to reduce the number of image layers
# created by docker, which reduces overall image size.
#
# After package installation, we remove any unnecessary packages
# and run `apt-get clean` to remove any downloaded package archives.
#
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y $PYTHON python-is-python3 \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

################################################
#
# Build stage
#
# Here we install development/build tools and fetch dependencies.
#
################################################
FROM base AS build

# TODO: install any build-time dependencies, such as tools needed to collect runtime deps

# Example: install `pip` and `awscli` so we can fetch Python dependencies.
# Re-run `apt-get update` in case the previous update was cached
# and is now out of date.
# Using `--no-cache-dir` avoids bloating the image with downloaded
# whl files.
#RUN apt-get update \
#    && apt-get install --no-install-recommends -y python3-pip \
#    && apt-get autoremove -y \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* \
#    && pip install --no-cache-dir 'awscli>=1.18.83'

# TODO: install any runtime dependencies into a known location

# Example: install Python deps from CodeArtifact
#
#COPY /requirements.txt /
#
# These need to be set in your environment as they are needed for the image build.
# They will not be available to the container at runtime.
#
# Leaving this to the latest possible point in the Dockerfile as these change on a regular
# basis. This allows Docker to cache previous layers, reducing build time.
#
#ARG AWS_DEFAULT_REGION=us-west-2
#ARG AWS_ACCESS_KEY_ID
#ARG AWS_SECRET_ACCESS_KEY
#ARG AWS_SESSION_TOKEN
#
# Get login credentials to pull artifacts from our AWS CodeArtifact
# and run `pip` to fetch dependencies from CodeArtifact.
# We also remove `awscli` once we're done with it so its Python packages
# aren't copied to the final container image. We also unset the index-url
# for CodeArtifact to avoid leaking them into the `test` stage.
#
#RUN aws codeartifact login --tool pip --repository seer_ds --domain seer --domain-owner 718843040700 \
#    && pip uninstall --no-input --yes --no-cache-dir awscli \
#    && pip install --no-input --no-cache-dir -r requirements.txt \
#    && pip config unset global.index-url

# TODO: install app files in the correct location
# Do this _after_ installing tools and deps to ensure better Docker layer caching
#COPY app /app
#COPY data /data

################################################
#
# Test stage
#
# Here we add test dependencies to the build container
# and define the command that will run the tests.
#
################################################
FROM build AS test

#
# Example: install pytest, pylint
#
#RUN pip install --no-input --no-cache-dir pytest pytest-cov pylint

#
# Copy tests from build context.
#
#COPY /tests /tests

#
# This entrypoint allows running tests (with coverage)
# by building with `--target test` and then running the
# resulting container. See README.md for more.
#
# Must run from `/` to ensure `tests/` can be located
# as a relative path (used for test data).
#
WORKDIR /
#TODO: Run an actual test command
CMD ["bash", "-c", "echo 'TODO: configure test command!' && false"]
#CMD ["pytest", "/app"]

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
LABEL description="TODO: describe this container"

#
# TODO: Copy dependencies from the build stage
# Example: copy installed Python packages.
#
#COPY --from=build /usr/local/lib/python3.8 /usr/local/lib/python3.8

#
# Copy the app from the build stage. This ensures we get the same files as build/test stages.
#
#COPY --from=build /app /app
#COPY --from=build /data /data
#COPY --from=build /entry.py /

# Scripts mostly do work in the current directory, so give them a dedicated space
WORKDIR /work

# TODO: set up the actual command
CMD ["bash", "-c", "echo 'TODO: configure test command!' && false"]
#CMD ["python", "/entry.py"]
