FROM ubuntu:trusty
MAINTAINER Gustavo Stor <gustavostor@tacc.utexas.edu>

VOLUME ["/data", "/backup"]

ADD . /src

ENTRYPOINT ["/src/entrypoint.sh"]
