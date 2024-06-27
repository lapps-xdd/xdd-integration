# xDD Integration

Repository that integrates all xDD processing into one Docker container. The container uses a directory mounted into `/data` and this directory should have the following structure:

```
.
├── metadata.json
├── scienceparse
└── text
```

When the container script runs it will read files from `text` and `scienceparse`. The metadata file is contains metadata for all files, see below for its expected syntax. 

Creating a Docker image and starting and entering the container:

```shell
docker build -t xdd .
docker run -it -v /Users/Shared/data/xdd/example:/data xdd bash
root@cd69e2d49b48:/app#
```

The docker-run command above assumes a local directory `/Users/Shared/data/xdd/example`, update that path as needed.

--

<span style="color: #ff0000">
This section, until the next horizontal line, needs to be updated.
</span> 
 
The container is not yet set up to deal with summarization using Ollama. For this you need to start the Ollama service and download the Llama3 model:

```shell
ollama start &
ollama pull llama3
```

The model is stored in `/root/.ollama/models`, this is different from what is said in the FAQ at [https://github.com/ollama/ollama/blob/main/docs/faq.md](https://github.com/ollama/ollama/blob/main/docs/faq.md).

> Note. That only happens when you pull as root, it did not happen later once I used systemctl to start ollama and then used `ollama pull <model-name>`.

At this point, when we remove the container we also lose the model, which is suboptimal since it was a 4GB+ download. For the models we should probably use a Docker volume, but for now we save the container into an image:

```shell
docker commit <container-name> xdd-llama3
```

This can take 5-10 minutes and it will create a 7GB image. You can start this image as usual:

```shell
docker run -it -v /Users/Shared/data/xdd/example:/data xdd-llama3 bash
root@cd69e2d49b48:/app#
```

While installing Ollama I got the following warning:

```
Step 3/9 : RUN curl -fsSL https://ollama.com/install.sh | sh
 ---> Running in 509b16bc561d
>>> Downloading ollama...
######################################################################## 100.0%#=#=#                                  ######################################################################## 100.0%
>>> Installing ollama to /usr/local/bin...
>>> Creating ollama user...
>>> Adding ollama user to video group...
>>> Adding current user to ollama group...
>>> Creating ollama systemd service...
WARNING: Unable to detect NVIDIA/AMD GPU. Install lspci or lshw to automatically detect and install GPU dependencies.
>>> The Ollama API is now available at 127.0.0.1:11434.
>>> Install complete. Run "ollama" from the command line.
Removing intermediate container 509b16bc561d
 ---> 619d9b548fe1
```

--

Running the code from inside the container:

```
root@cd69e2d49b48:/app# sh run.sh
```

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

This includes intermediate files in the `doc`, `mer`, `ner`, `pos` and `trm` directories, and the final output in the form of a JSON file `/data/output/ela/elastic.json`, which can be used for a batch import to ElasticSearch.


### Metadata file

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


### Preocessing details

This repository integrates processing from three repositories:

- [https://github.com/lapps-xdd/xdd-docstructure](https://github.com/lapps-xdd/xdd-docstructure)
- [https://github.com/lapps-xdd/xdd-processing](https://github.com/lapps-xdd/xdd-processing)
- [https://github.com/lapps-xdd/xdd-terms.git](https://github.com/lapps-xdd/xdd-terms.git)

And it runs the following steps:

1. document structure parser
2. spaCy NER
3. term extraction
4. merging layers
5. creating ElasticSearch file

Step 1 is implemented in [https://github.com/lapps-xdd/xdd-docstructure](https://github.com/lapps-xdd/xdd-docstructure), steps 2, 4 and 5 in [https://github.com/lapps-xdd/xdd-processing](https://github.com/lapps-xdd/xdd-processing), and step 4 in [https://github.com/lapps-xdd/xdd-terms.git](https://github.com/lapps-xdd/xdd-terms.git).