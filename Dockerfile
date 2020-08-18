FROM python:3.8-slim-buster

ENV RELEASE=20c
ENV MAJOR=20
ENV MINOR=3

RUN apt update\
    && apt install -y curl git zip unzip gdal-bin gnupg jq\
    && apt autoclean -y

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list\
    && curl -O https://www.postgresql.org/media/keys/ACCC4CF8.asc\
    && apt-key add ACCC4CF8.asc\
    && apt update\
    && apt install -y postgresql-client-12\
    && rm ACCC4CF8.asc

RUN curl -O https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2020-06-26T19-56-55Z\
    && mv mc.RELEASE.2020-06-26T19-56-55Z mc\
    && chmod +x mc\
    && mv ./mc /usr/bin

WORKDIR /geocode

RUN FILE_NAME=linux_geo${RELEASE}_${MAJOR}_${MINOR}.zip\
    && echo $FILE_NAME\
    && curl -O https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/$FILE_NAME\
    && unzip *.zip\
    && rm *.zip

ENV GEOFILES=/geocode/version-${RELEASE}_${MAJOR}.${MINOR}/fls/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/geocode/version-${RELEASE}_${MAJOR}.${MINOR}/lib/

WORKDIR /

COPY requirements.txt /requirements.txt
RUN pip install --upgrade pip\
    && pip install -r requirements.txt
