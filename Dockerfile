FROM ubuntu:14.04
MAINTAINER Gustavo Stor <gustavostor@gmail.com>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
    echo "deb http://repo.mo    ngodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
    apt-get update && \
    apt-get install -y mongodb-org-shell mongodb-org-tools python-pip && \
    echo "mongodb-org-shell hold" | dpkg --set-selections && \
    echo "mongodb-org-tools hold" | dpkg --set-selections && \
    pip install awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    mkdir /backup

ENV CRON_TIME="0 7 * * *"

VOLUME ["/backup"]

RUN mkdir -p /src
ADD . /src
WORKDIR /src

CMD bash /src/entrypoint.sh
