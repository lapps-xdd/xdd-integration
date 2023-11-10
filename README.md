# xDD Integration

Repository that integrates all xDD processing into one Docker container. The container uses a directory mounted into `/data` and this directory should have the following structure:

```
data
├── metadata.json
├── scienceparse
└── text
```

When the container script runs it will read files from `text` and `scienceparse`. The metadata file is contains metadata for all files, see below for its expected syntax. 

Creating a Docker image and starting and entering the container:

```
$ docker build -t xdd .
$ docker run --rm -it -v /Users/Shared/data/xdd/doc2vec/topic_doc2vecs/biomedical:/data xdd bash
root@cd69e2d49b48:/app#
```

The docker-run command above assumes a local directory `/Users/Shared/data/xdd/doc2vec/topic_doc2vecs/biomedical`, update that path as needed.

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

<!--

This repository integrates processing from three repositories:

- [https://github.com/lapps-xdd/xdd-docstructure](https://github.com/lapps-xdd/xdd-docstructure)
- [https://github.com/lapps-xdd/xdd-processing](https://github.com/lapps-xdd/xdd-processing)
- [https://github.com/lapps-xdd/xdd-terms.git](https://github.com/lapps-xdd/xdd-terms.git)

-->