FROM python:3.11.6-slim-bookworm

RUN apt-get -y update && apt-get install -y git

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

RUN git clone https://github.com/lapps-xdd/xdd-docstructure code/xdd-docstructure \
	&& git clone https://github.com/lapps-xdd/xdd-processing code/xdd-processing \
	&& git clone https://github.com/lapps-xdd/xdd-terms code/xdd-terms

COPY run.sh .
