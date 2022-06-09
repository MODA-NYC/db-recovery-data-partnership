FROM python:3.8-slim-buster

ENV RELEASE=20c
ENV MAJOR=20
ENV MINOR=3
ENV GIT_TRACE_CURL=1

RUN apt update\
    && apt install -y curl git zip unzip gdal-bin gnupg jq\
    && apt autoclean -y

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list\
    && curl -O https://www.postgresql.org/media/keys/ACCC4CF8.asc\
    && apt-key add ACCC4CF8.asc\
    && apt update\
    && apt install -y postgresql-client-12\
    && rm ACCC4CF8.asc

RUN curl -O https://dl.min.io/client/mc/release/linux-amd64/mc\
    && chmod +x mc\
    && mv ./mc /usr/bin

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"\
    && unzip awscliv2.zip\
    && ./aws/install

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

ENV http_proxy=http://mspapi-ctwbcp01.nycnet:8080
ENV https_proxy=http://mspapi-ctwbcp01.nycnet:8080
#ENV ssh_proxy='ProxyCommand=connect -H http://mspapi-ctwbcp01.nycnet:1080 %h %p'
#RUN git config --global core.sshCommand "ssh -o '$ssh_proxy'"
#The noted way makes the proxy available only for this RUN instruction.
#If the whole image should use the proxy the ENV instruction should be used:

#
#RUN export http_proxy=${http_proxy}
#RUN export https_proxy=${https_proxy}