FROM debian:jessie
MAINTAINER Henrrich <huanghe389@gmail.com>

ARG SC_VERSION=4.4.1

WORKDIR /usr/local/sauce-connect

RUN apt-get update && apt-get install -y \
    wget

RUN wget https://saucelabs.com/downloads/sc-$SC_VERSION-linux.tar.gz -O - | tar -xz

RUN mv sc-$SC_VERSION-linux/* ./ && rm -rf sc-$SC_VERSION-linux

ENTRYPOINT ["/usr/local/sauce-connect/bin/sc"]

CMD ["--version"]

