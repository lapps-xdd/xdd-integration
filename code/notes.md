
The requirements file used to just have

```
spacy==3.5.1
en-core-web-sm @ https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.5.0/en_core_web_sm-3.5.0-py3-none-any.whl
```

This was replaced with a full freeze since the above would install numpy==2.0.0 and cause compatibility issues. In fact, what was done was to get a pip-freeze from an older image and then just do "pip install langchain==0.1.17" and then do the freeze to create requirements.txt.


Some trouble with running systemctl on the container:

```
exouser@xdd-llms-medium:~/xdd-integration/code$ docker run --rm -it xdd:cuda bash
root@59022e43b7e7:/app# systemctl
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
root@59022e43b7e7:/app# ollama start &
[1] 14
root@59022e43b7e7:/app# Couldn't find '/root/.ollama/id_ed25519'. Generating new private key.
Your new public key is:

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPz1jLXICvIXF5jPhqI1nqLJ0PhuHfZxjSuImCKFG+o
```
