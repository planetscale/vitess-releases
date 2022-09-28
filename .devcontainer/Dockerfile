# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.203.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use hirsuite or bionic on local arm64/Apple Silicon): hirsute, focal, bionic
ARG VARIANT="hirsute"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && RUNLEVEL=1 apt-get -y install --no-install-recommends libarchive-tools build-essential unzip g++ etcd ant maven default-jdk ruby ruby-dev rubygems build-essential rpm mysql-server mysql-client \
    && gem install --no-document fpm \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Create planetscale user to compile code
RUN useradd --password "" --create-home  "planetscale" -s /bin/bash \
    && adduser planetscale sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Clone and install vitess to run locally
RUN cd /home/planetscale \
    && git clone https://github.com/vitessio/vitess.git \
    && cd /home/planetscale/vitess \
    && chown planetscale:planetscale -R /home/planetscale
