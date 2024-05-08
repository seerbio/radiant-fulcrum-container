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
You can then use the Docker command line to run Pythia and Scry workflows.

```shell
docker run --rm -it -v $PWD:/data 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry scry <arguments>
```

While many steps can access data from cloud locations, you will likely
need to give the container access to local folders using `-v` arguments.
For example, `-v $PWD:/data` gives the container access to your working
directory by mounting it at `/data/`.

### Advanced Usage

To launch an interactive environment with Pythia and Scry installed, simply
run the container without arguments:

```shell
$ docker run --rm -it -v $PWD:/data 718843040700.dkr.ecr.us-west-2.amazonaws.com/seer/pythia-scry
# _
```

You can also run any shell command inside the container directly from the Docker command.
For example, to run just Pythia:

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
