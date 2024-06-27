FROM python:3.11.6-slim-bookworm

# for final production image remove tree and emacs
RUN apt-get -y update && apt-get install -y git curl systemctl tree emacs

RUN curl -fsSL https://ollama.com/install.sh | sh

WORKDIR /app

COPY requirements.txt setup.sh .

RUN pip install -r requirements.txt

# Just cloning the repositories, the run.sh script will pull and checkout as needed
RUN git clone https://github.com/lapps-xdd/xdd-docstructure code/xdd-docstructure \
	&& git clone https://github.com/lapps-xdd/xdd-processing code/xdd-processing \
	&& git clone https://github.com/lapps-xdd/xdd-LLMs code/xdd-llms \
	&& git clone https://github.com/lapps-xdd/xdd-terms code/xdd-terms

RUN sh setup.sh

COPY run.sh . 