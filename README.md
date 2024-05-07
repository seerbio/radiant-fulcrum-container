# Template for Docker projects

## Using this template

1. Create a new repository for your project by following
   [GitHub's documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).
2. Update `Dockerfile` and `README.md` (this file) to define the project's
   name and configuration. You MUST define a command that runs in the `test`
   stage that checks the container.

   Remove references to `docker-project-template` in the following files:

   - `.github/workflows/build.yml`
   - `.github/workflows/publish.yml`
   - `README.md` (this file)

3. Document the installation and usage of your project in `README.md` (this
   file).
4. Follow the instructions in `CONTRIBUTING.md` to contribute to the project.

## Installation

This container can be installed with the Docker CLI:

```shell
docker run seer/docker-project-template-CHANGEME [args]
```

## Basic Usage

TODO: describe using this container.
At a minimum, include a brief demo of using the library from the Python REPL:

```shell
$ docker run seer/docker-project-template-CHANGEME [args]
Some amazing output goes here: Hello World.
```

## Testing the container

This container is set up to use a multi-stage build, including a `test` stage
that installs both the app and related test code and dependencies. To build and
run tests in the container, just run `test-container.sh`.

```shell
./test-container.sh
```

This test script will also be run by GitHub actions on all PRs and whenever
changes are pushed or merged to the `main` branch.
