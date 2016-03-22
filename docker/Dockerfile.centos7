FROM centos:7

RUN yum -y update

# Additional tooling
RUN yum install -y git
RUN yum install -y curl
RUN yum install -y mercurial
RUN yum install -y subversion
RUN yum install -y unzip
RUN yum install -y tar

# Build tools
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y glibc-devel
RUN yum install -y make
RUN yum install -y rpm-build

# Ruby dependencies
RUN yum install -y openssl-devel
RUN yum install -y readline-devel
RUN yum install -y zlib-devel

# Install Ruby via rbenv
RUN git clone https://github.com/sstephenson/rbenv.git  ~/.rbenv
RUN echo 'export PATH="/root/.rbenv/bin:$PATH"' >> /etc/profile.d/rbenv
ENV PATH /root/.rbenv/bin:$PATH
RUN git clone https://github.com/sstephenson/ruby-build.git  ~/.rbenv/plugins/ruby-build
RUN source /etc/profile
RUN rbenv install 2.1.5
ENV PATH /root/.rbenv/versions/2.1.5/bin:$PATH

# Update rubygems and don't install docs
RUN gem update --system --verbose
RUN echo "gem: --no-document" >> ~/.gemrc

# Install fpm-cookery
RUN gem install fpm-cookery -v 0.31.0

# Remove strict host key checking for SSH
RUN echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

# Set an entry point to simplify command execution
ENTRYPOINT ["/root/.rbenv/versions/2.1.5/bin/fpm-cook"]
