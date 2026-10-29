# Radiant DIA + Fulcrum Pipeline Docker image

Radiant DIA™ is a peptide-centric search engine for bottom-up DIA proteomics.
Alone, it generates only basic IDs and statistics, but using it within
the larger Fulcrum Pipeline™ ecosystem allows executing full-fledged processing
workflows with various rescoring, FDR, and output options.

This Docker container image permits easily executing Radiant + Fulcrum
workflows using local compute resources.

## Usage

### Getting started

To run this container you will need to first install Docker: 
[Docker installation guide](https://docs.docker.com/get-docker/)  

It's easiest to do this on Linux (for example, an EC2 instance):

```shell
# Ubuntu
sudo apt install -y docker.io
```

You can now use the `docker run` command to run Radiant and Fulcrum workflows.

<details>
<summary>Getting the latest container version</summary>

To download the newest version of the container from Docker Hub, run the following commands:

```shell
docker pull seerbio/radiant-fulcrum:latest
```
</details>

<details>
<summary>Getting a specific container version</summary>
You can also download a specific [release](https://github.com/seerbio/radiant-fulcrum-container/releases) of the container:

**Note:** this is _not_ the Radiant DIA version, but the version of this container!

```shell
docker pull seerbio/radiant-fulcrum:2.3.1

# Major/minor versions also work
docker pull seerbio/radiant-fulcrum:2.3
```
</details>

#### Accessing data files

While many steps can access data from cloud locations by using `s3://` URIs,
accessing local files requires you give the container access to local folders
using `-v` arguments to the `docker run` command. For example, `-v $PWD:/data`
gives the container access to your working directory by mounting it at `/data/`
inside the container.

### Running the workflow

To run the default Radiant workflow on your data files, use the following command:

```shell
docker run --rm -it -v "$PWD:/data/" seerbio/radiant-fulcrum sh -c 'radiant_fulcrum -v --libfree --library /data/library.tsv --fasta /data/database.fasta --results-dir /data/radiant-output/ /data/*.mzML'
```

**Note:** When using wildcards (like `*.mzML`), you must wrap the command with `sh -c '...'`
to enable shell expansion. For commands without wildcards, you can pass arguments directly:
`docker run ... radiant_fulcrum --help`

This will run the library-free workflow on all `mzML` files in the current directory, using `library.tsv` and
`database.fasta` from the current directory, and writing results to the `radiant-output/` folder.

For a full list of supported parameters, see documentation for the [Radiant workflow](https://github.com/seerbio/radiant-fulcrum-workflow).

You can also get help by running:
```shell
docker run --rm -it seerbio/radiant-fulcrum radiant_fulcrum --help
```

### Advanced Usage

If the default workflow doesn't support your use case, you can run a customized Fulcrum workflow by generating your
own TOML configuration file.

Fulcrum is configured with a TOML file. While it's possible to [run Radiant directly](#running-radiant-dia-directly),
running within a Fulcrum workflow allows processing multiple files with
rescoring, FDR estimation, and protein inference/rollup. For most Radiant +
Fulcrum runs, start with the recommended `workflow = "radiant"` example. It
uses the workflow defaults while allowing the main search settings to be
configured in one place.

<details>
<summary>Getting started with the recommended Radiant workflow</summary>

Start with the recommended Radiant workflow example:
```shell
docker run --rm -it -v "$PWD:/data/" seerbio/radiant-fulcrum cp /examples/example_radiant_workflow.toml /data/
```

You can then edit the `example_radiant_workflow.toml` file in the current directory.
Be sure to update the `library`, `fasta`, and `mzml` paths as needed. **You will
need to make sure files are accessed using their path in the container**; see
[Accessing data files](#accessing-data-files) below.

To run your workflow:

```shell
docker run --rm -it -v "$PWD:/data/" seerbio/radiant-fulcrum fulcrum -v --toml-file /data/example_radiant_workflow.toml
```
</details>

For more detailed control over individual Fulcrum stages, see the lower-level
`v1` and `mbr` examples in [`examples/`](examples/). The `v1_write_library`
example is provided for library-export workflows.

To learn more about configuring Radiant and Fulcrum, see [`examples/`](examples/)

To launch an interactive environment with Radiant and Fulcrum installed,
run the container with `bash`:

```shell
$ docker run --rm -it -v $PWD:/data seerbio/radiant-fulcrum bash
# _
```

#### Running Radiant DIA directly

You can run any executable inside the container directly from the Docker command.
For example:

```shell
$ docker run --rm -it -v $PWD:/data seerbio/radiant-fulcrum RadiantDIA --help
"Expected 4 arguments.  Received 2"
Usage: /usr/local/bin/radiant/RadiantDIA [options] fraglibff-path fasta-path radiant-path data-file-path

Options:
  -h, --help  Displays help on commandline options.
  --help-all  Displays help including Qt specific options.

Arguments:
  fraglibff-p *.fragLibFF file
  ath
  fasta-path  *.fasta file
  radiant-path *.radiantConfig file
  data-file-p data directory path
  ath
```
