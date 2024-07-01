# xDD Integration

Repository that integrates all xDD processing into one Docker container. The container uses a directory mounted into `/data` and this directory should have the following structure:

```
.
├── metadata.json
├── scienceparse
└── text
```

When the container script runs it will read files from `text` and `scienceparse`. The metadata file contains metadata for all files, see below for its expected syntax.


## Processing without the summarizer

Creating a Docker image and starting and entering the container:

```shell
docker build -t xdd .
docker run -it -v /Users/Shared/data/example:/data xdd bash
root@cd69e2d49b48:/app#
```

The docker-run command above assumes a local directory `/Users/Shared/data/example`, update that path as needed.


## Processing with the summarizer

This does not work (or work very slowly) without a 8GB GPU. To run a Docker container and have it use the GPU on the host there are some requirements (this is following instructions at [https://www.howtogeek.com/devops/how-to-use-an-nvidia-gpu-with-docker-containers/](https://www.howtogeek.com/devops/how-to-use-an-nvidia-gpu-with-docker-containers/)).

First your Docker host needs to have a GPU. Test this with the `nvidia-smi` command.

Then you want to add the  NVIDIA Container Toolkit to your host, see [https://github.com/NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker). First step there is to get the package repository


```shell
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

This does give a depreciation warning for apt-key, but it does seem to succeed.

Next install the nvidia-docker2 package on your host:

```shell
sudo apt-get update
sudo apt-get install -y nvidia-docker2
```

Restart the Docker daemon to complete the installation:

```shell
sudo systemctl restart docker
```

> Note that while the above still works it is outdated since nvidia-docker2 is now deprecated. Instead use what is at [https://github.com/NVIDIA/nvidia-container-toolkit](https://github.com/NVIDIA/nvidia-container-toolkit). Instructions here will be updated asap.


### Building and starting the container

To build the container do:

```shell
cd code
docker build -t xdd-all -f Dockerfile.cuda .
```

This can take 5-10 minutes and will build a Docker image of about 9GB in size. To start the image you need to specifically state that the container should use the GPU on the host:

```shell
docker run --gpus all --rm -it -v /Users/Shared/data/example:/data xdd-all bash
```

Before starting the script you need to start the Ollama service (this is currently not done by the run script):

```shell
root@cd69e2d49b48:/app ollama start &
```

Give this about 5 seconds to finish, then run the code from inside the container:

```
root@cd69e2d49b48:/app# sh run-all.sh
```


### Output

Output is written to a new directory on the container named `/data/output` and therefore also to the local mounted directory. The structure of the output directory is

```
output/
├── doc
├── ela
├── mer
├── ner
├── pos
├── sum
└── trm
```

This includes intermediate files in the `doc`, `mer`, `ner`, `pos`, `sum` and `trm` directories (note that `sum` will only be created if using the code that includes the summarizer), and the final output in the form of a JSON file `/data/output/ela/elastic.json`, which can be used for a batch import to ElasticSearch.


## Metadata file

This is assumed to be  a list of metadata records, each with the folowing structure:

```json
{
    "identifier": [
        { "type": "_xddid", "id": "5786fb89cf58f168a07dd191" },
        { "type": "doi", "id": "10.1002/ajhb.22797" }
    ],
    "_gddid": "5786fb89cf58f168a07dd191",
    "title": "The allocation and interaction model: A new model for predicting total energy expenditure of highly active humans in natural environments",
    "type": "article",
    "journal": {
        "name": "American Journal of Human Biology"
    },
    "link": [
        {
            "url": "http://doi.wiley.com/10.1002/ajhb.22797",
            "type": "publisher"
        }
    ],
    "author": [
        { "name": "Ocobock, Cara" }
    ],
    "publisher": "Wiley",
    "volume": "28",
    "number": "3",
    "pages": "372--380",
    "year": "2016"
},
```

At the moment, the only fields that are extracted are title, year and authors. The code will not break if the fields in `metadata.json` do not comply, but there won't be any results.


## Processing chain details

This repository integrates processing from four repositories:

1. [https://github.com/lapps-xdd/xdd-docstructure](https://github.com/lapps-xdd/xdd-docstructure)
2. [https://github.com/lapps-xdd/xdd-processing](https://github.com/lapps-xdd/xdd-processing)
3. [https://github.com/lapps-xdd/xdd-terms.git](https://github.com/lapps-xdd/xdd-terms.git)
4. [https://github.com/lapps-xdd/xdd-LLMs.git](https://github.com/lapps-xdd/xdd-LLMs.git)

And it runs the following steps:

1. document structure parser (reporitory 1)
2. spaCy NER (reporitory 2)
3. term extraction (reporitory 3)
4. summarization (reporitory 4)
5. merging layers (reporitory 2)
6. creating ElasticSearch file (reporitory 2)
