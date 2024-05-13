# Pythia + Scry Docker image

Pythia is a peptide-centric search engine for bottom-up DIA proteomics.
Alone, it generates only basic IDs and statistics, but using it within
the larger Scry ecosystem allows executing full-fledged processing
workflows with various rescoring, FDR, and output options.

This Docker container image permits easily executing Pythia + Scry
workflows using local compute resources.

## Usage

### Basic Usage

To run this container you will need to first install Docker.
You can then use the `docker run` command to run Pythia and Scry workflows.

```shell
docker run --rm -it -v $PWD:/data 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry scry <arguments>
```

#### Scry workflows

While it's possible to [run Pythia directly](#running-pythia-directly),
running within a Scry workflow provides access to advanced rescoring,
FDR estimation, and output functionality. Scry is configured with a
simple TOML file. For example:

<details>
<summary>Example Scry workflow TOML</summary>

```toml
workflow = "v0"  # Use the basic built-in workflow


# Search settings
[search]
backend = "pythia"  # Use Pythia to search files

location = […]  # mzML path(s)
library = "/data/library.tsv"
fasta = "/data/uniprot.fasta"
config = "/data/examples/example_pythia_params.exploris.toml"

scoring = "svm"  # Scores to be used downstream; `svm` is a built-in set of defaults


# Rescoring settings
[airpot]
backend = "mokapot"  # Percolator-style rescoring with Mokapot


# FDR settings
[cortado]
backend = "crema"
method = "mixmax"  # Use MixMax FDR estimates, suitable for peptide-centric search
pep_fdr_type = "psm-only"   # Compute global PSM FDR


# Output settings
[output]
backend = "write_csv"
location = "/data/scry-output/"
```
</details>

#### Accessing data files

While many steps can access data from cloud locations by using `s3://` URIs,
accessing local files requires you give the container access to local folders
using `-v` arguments to the `docker run` command. For example, `-v $PWD:/data`
gives the container access to your working directory by mounting it at `/data/`
inside the container.

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
