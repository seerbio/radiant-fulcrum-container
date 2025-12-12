# Pythia + Scry Docker image

Pythia is a peptide-centric search engine for bottom-up DIA proteomics.
Alone, it generates only basic IDs and statistics, but using it within
the larger Scry ecosystem allows executing full-fledged processing
workflows with various rescoring, FDR, and output options.

This Docker container image permits easily executing Pythia + Scry
workflows using local compute resources.

## Usage

### Getting started

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

<details>
<summary>Getting the latest container version</summary>

To download the newest version of the container from ECR, run the following commands:

```shell
aws ecr get-login-password | docker login --username AWS --password-stdin 718843040700.dkr.ecr.us-west-2.amazonaws.com
docker pull 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry:latest
```
</details>

<details>
<summary>Getting a specific container version</summary>
You can also download a specific [release](https://github.com/seerbio/pythia-scry-container/releases) of the container:

**Note:** this is _not_ the Pythia version, but the version of this container!

```shell
docker pull 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry:0.3.0

# Major/minor versions also work
docker pull 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry:0.3
```
</details>

#### Accessing data files

While many steps can access data from cloud locations by using `s3://` URIs,
accessing local files requires you give the container access to local folders
using `-v` arguments to the `docker run` command. For example, `-v $PWD:/data`
gives the container access to your working directory by mounting it at `/data/`
inside the container.

### Running the Pythia workflow

To run the default Pythia workflow on your data files, use the following command:

```shell
docker run --rm -it -v "$PWD:/data/" 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry 'pythia_scry -v --libfree --library /data/library.tsv --fasta /data/database.fasta --results-dir /data/pythia_output/ /data/*.mzML'
```

This will run the library-free workflow on all `mzML` files in the current directory, using `library.tsv` and
`database.fasta` from the current directory, and writing results to the `pythia_output/` folder.

For a full list of supported parameters, see documentation for the [Pythia workflow](https://github.com/seerbio/scry-pythia-workflow).

You can also get help by running:
```shell
docker run --rm -it -v "$PWD:/data/" 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry 'pythia_scry --help'
```

### Advanced Usage

If the default Pythia workflow doesn't support your use case, you can
run a fully customized Scry workflow by generating your own TOML configuration file.

To run a Scry workflow in a container, use `docker run`:

```shell
docker run --rm -it 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry 'scry -v --toml-file /examples/example_scry_workflow.toml'
```

While it's possible to [run Pythia directly](#running-pythia-directly),
running within a Scry workflow allows processing multiple files with
rescoring, FDR estimation, and protein inference/rollup. Scry is
configured with a simple TOML file.

<details>
<summary>Getting started with Scry</summary>

Start with an example workflow:
```shell
docker run --rm -it -v "$PWD:/data/" 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry 'cp /examples/example_scry_workflow.toml /data/'
```

You can then edit the `example_scry_workflow.toml` file in the current directory.
Be sure to update the `search.location` and `ouput` `location` settings! **You will
need to make sure files are accessed using their path in the container**; see
[Accessing data files](#accessing-data-files) below.

To run your workflow:

```shell
docker run --rm -it -v "$PWD:/data/" 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry 'scry -v --toml-file /data/example_scry_workflow.toml'
```
</details>

To learn more about configuring Scry and Pythia, see [`examples/`](examples/)

To launch an interactive environment with Pythia and Scry installed, simply
run the container without arguments:

```shell
$ docker run --rm -it -v $PWD:/data 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry
# _
```

#### Running Pythia directly

You can also run any shell command inside the container directly from the Docker command.
For example:

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
