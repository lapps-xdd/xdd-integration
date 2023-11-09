FROM python:3.11.6-bookworm

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

RUN git clone https://github.com/lapps-xdd/xdd-docstructure code/xdd-docstructure \
	&& git clone https://github.com/lapps-xdd/xdd-processing code/xdd-processing \
	&& git clone https://github.com/lapps-xdd/xdd-terms code/xdd-terms

COPY run.sh .
