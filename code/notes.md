
The requirements file used to just have

```
spacy==3.5.1
en-core-web-sm @ https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.5.0/en_core_web_sm-3.5.0-py3-none-any.whl
```

This was replaced with a full freeze since the above would install numpy==2.0.0 and cause compatibility issues. In fact, what was done was to get a pip-freeze from an older image and then just do "pip install langchain==0.1.17" and then do the freeze to create requirements.txt.
