# XDD Integration

Repository that integrates all XDD processing into one Docker container. The container uses a directory mounted into `/data` and this directory should have the following structure:

```
data
├── metadata.json
├── scienceparse
└── text
```

When the container script runs it will read files from `text` and `scienceparse`. The metadata file is optional and contains metadata for all files. If no metadata file is present the container needs to access the XDD API. 

The final output and intermediate files are written to a new directory named `output`. The final output JSON files that can be used for a batch import to ElasticSearch.

This repository integrates processing from three repositories:

- [https://github.com/lapps-xdd/xdd-docstructure](https://github.com/lapps-xdd/xdd-docstructure)
- [https://github.com/lapps-xdd/xdd-processing](https://github.com/lapps-xdd/xdd-processing)
- [https://github.com/lapps-xdd/xdd-terms.git](https://github.com/lapps-xdd/xdd-terms.git)

Creating a Docker image and starting and entering the container:

```bash
$ docker build -t xdd .
$ docker run --rm -it -v /Users/Shared/data/xdd/doc2vec/topic_doc2vecs/biomedical:/data xdd bash
```

The docker-run command assumes a local directory `/Users/Shared/data/xdd/doc2vec/topic_doc2vecs/biomedical`, update the path as needed.

Running the code from inside the container:

```bash
$ cd code
$ python run.py
```

However, the current version doesn't really do anything yet.