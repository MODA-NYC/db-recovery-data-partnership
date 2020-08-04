FROM python:3.8-slim-buster

ARG RELEASE=20a
ARG MAJOR=20
ARG MINOR=1
ARG PATCH=0

ENV RELEASE=${RELEASE}
ENV MAJOR=${MAJOR}
ENV MINOR=${MINOR}
ENV PATCH=${PATCH}

RUN apt update\
    && apt install -y\
    curl git unzip\
    && apt autoclean

RUN sudo tee /etc/apt/sources.list.d/pgdg.list << END\
    && deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main\
    END\
    && curl -O https://www.postgresql.org/media/keys/ACCC4CF8.asc\
    && sudo apt-key add ACCC4CF8.asc

    && sudo apt update
    && sudo apt install -y postgresql-client-11 gdal-bin
    && sudo apt autoremove
    && rm ACCC4CF8.asc

RUN curl -O https://dl.min.io/client/mc/release/linux-amd64/mc\
    && chmod +x mc\
    && sudo mv ./mc /usr/bin\

WORKDIR /geocode
COPY . . 

RUN FILE_NAME=linux_geo${RELEASE}_${MAJOR}_${MINOR}.zip\
    && echo $FILE_NAME\
    && curl -O https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/$FILE_NAME\
    && unzip *.zip\
    && rm *.zip

RUN ./patch.sh

ENV GEOFILES=/geocode/version-${RELEASE}_${MAJOR}.${MINOR}/fls/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/geocode/version-${RELEASE}_${MAJOR}.${MINOR}/lib/
    
RUN pip install --upgrade pip\
    && pip install python-geosupport pandas numpy sqlalchemy psycopg2-binary usaddress beautifulsoup4

WORKDIR /