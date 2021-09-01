FROM ubuntu:18.04

RUN apt-get update -y && apt-get install -y sudo build-essential wget make unzip g++ etcd curl git wget vim ant maven default-jdk ruby ruby-dev rubygems build-essential rpm mysql-server mysql-client
RUN gem install --no-document fpm

RUN useradd --password "" --create-home  "planetscale"
RUN adduser planetscale sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN cd /tmp && \
    wget https://dl.google.com/go/go1.17.linux-amd64.tar.gz && \
    tar -xvf go1.17.linux-amd64.tar.gz && \
    mv go /usr/local

USER planetscale
ENV GOROOT=/usr/local/go
ENV GOPATH=/home/planetscale/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
RUN mkdir -p /home/planetscale/go/src/vitess.io/ && \
    cd /home/planetscale/go/src/vitess.io/ && \
    git clone https://github.com/vitessio/vitess.git
WORKDIR /home/planetscale/go/src/vitess.io/vitess
RUN git remote add planetscale https://github.com/planetscale/vitess.git && \
    git fetch planetscale && \
    make tools

CMD ["/bin/bash"]
