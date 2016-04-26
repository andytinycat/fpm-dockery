FROM ubuntu:16.04

RUN apt-get update

# Additional tooling
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y mercurial
RUN apt-get install -y subversion
RUN apt-get install -y unzip
RUN apt-get install -y puppet

# Build tools
RUN apt-get install -y build-essential
RUN apt-get install -y ruby2.3 ruby2.3-dev

# Update rubygems and don't install docs
RUN gem2.3 update --system --verbose
RUN echo "gem: --no-document" >> ~/.gemrc

# Install fpm-cookery
RUN gem2.3 install fpm-cookery -v 0.31.0

# Remove strict host key checking for SSH
RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

# Set an entry point to simplify command execution
ENTRYPOINT ["/usr/local/bin/fpm-cook"]
