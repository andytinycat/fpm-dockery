FROM ubuntu:15.04

RUN apt-get update

# Additional tooling
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y mercurial
RUN apt-get install -y subversion
RUN apt-get install -y unzip

# Build tools
RUN apt-get install -y build-essential

# Install Ruby from Brightbox's PPA
RUN apt-get -y install software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get -y install ruby2.1
RUN apt-get -y install ruby2.1-dev

# Update rubygems and don't install docs
RUN gem update --system --verbose
RUN echo "gem: --no-document" >> ~/.gemrc

# Install fpm-cookery
RUN gem install fpm-cookery -v 0.31.0

# Remove strict host key checking for SSH
RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

# Set an entry point to simplify command execution
ENTRYPOINT ["/usr/local/bin/fpm-cook"]
