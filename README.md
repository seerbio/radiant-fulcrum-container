# Pythia + Scry Docker image

Pythia is a peptide-centric search engine for bottom-up DIA proteomics.
Alone, it generates only basic IDs and statistics, but using it within
the larger Scry ecosystem allows executing full-fledged processing
workflows with various rescoring, FDR, and output options.

This Docker container image permits easily executing Pythia + Scry
workflows using local compute resources.

## Usage

<details>
<summary>Getting started</summary>

To run this container you will need to first install Docker.
It's easiest to do this on Linux (for example, an EC2 instance):

```shell
# Ubuntu
sudo apt install -y docker.io
```

To download the container, you must authenticate to the AWS ECR repository:
```shell
aws ecr get-login-password | docker login --username AWS --password-stdin 718843040700.dkr.ecr.us-west-2.amazonaws.com
```

You can now use the `docker run` command to run Pythia and Scry workflows.
</details>

#### Scry workflows

To run a Scry workflow in a container, use `docker run`:

```shell
docker run --rm -it 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry 'scry -v --toml-file /examples/example_scry_workflow.toml'
```

While it's possible to [run Pythia directly](#running-pythia-directly),
running within a Scry workflow allows processing multiple files with
rescoring, FDR estimation, and protein inference/rollup. Scry is
configured with a simple TOML file.

To learn more about configuring Scry and Pythia, see [`examples/`](examples/)

#### Accessing data files

While many steps can access data from cloud locations by using `s3://` URIs,
accessing local files requires you give the container access to local folders
using `-v` arguments to the `docker run` command. For example, `-v $PWD:/data`
gives the container access to your working directory by mounting it at `/data/`
inside the container.

#### Getting the latest version

To download the newest version of the container from ECR, run the following commands:

```shell
aws ecr get-login-password | docker login --username AWS --password-stdin 718843040700.dkr.ecr.us-west-2.amazonaws.com
docker pull 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry:latest
```

<details>
<summary>Getting a specific version</summary>
You can also download a specific [release](https://github.com/seerbio/pythia-scry-container/releases) of the container:

**Note:** this is _not_ the Pythia version, but the version of this container!

```shell
docker pull 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry:0.3.0

# Major/minor versions also work
docker pull 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry:0.3
```
</details>

### Advanced Usage

To launch an interactive environment with Pythia and Scry installed, simply
run the container without arguments:

```shell
$ docker run --rm -it -v $PWD:/data 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry
# _
```

You can also run any shell command inside the container directly from the Docker command.
For example:

#### Running Pythia directly

```shell
$ docker run --rm -it -v $PWD:/data 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry PythiaDIA --help
"Expected 4 arguments.  Received 2"
Usage: /usr/local/bin/PythiaDIACpp/PythiaDIA [options] fraglibff-path fasta-path pythia-path data-file-path

Options:
  -h, --help  Displays help on commandline options.
  --help-all  Displays help including Qt specific options.

Arguments:
  fraglibff-p *.fragLibFF file
  ath
  fasta-path  *.fasta file
  pythia-path *.pythia file
  data-file-p data directory path
  ath
```
