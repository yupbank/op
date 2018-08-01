FROM ubuntu:14.04

# File Author / Maintainer
MAINTAINER Peng YU <peng.yu@shopify.com>

# Switch to root for install
USER root

# Install wget
RUN apt-get update -y && apt-get install -y \
	wget \
	build-essential \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# Install glpk from http
# instructions and documentation for glpk: http://www.gnu.org/software/glpk/
WORKDIR /user/local/
RUN wget http://ftp.gnu.org/gnu/glpk/glpk-4.45.tar.gz \
	&& tar -zxvf glpk-4.45.tar.gz

## Verify package contents
# RUN wget http://ftp.gnu.org/gnu/glpk/glpk-4.57.tar.gz.sig \
#	&& gpg --verify glpk-4.57.tar.gz.sig
#	#&& gpg --keyserver keys.gnupg.net --recv-keys 5981E818

WORKDIR /user/local/glpk-4.45
RUN ./configure \
	&& make \
	&& make check \
	&& make install \
	&& make distclean \
	&& ldconfig \
# Cleanup
	&& rm -rf /user/local/glpk-4.45.tar.gz \
	&& apt-get clean

#create a glpk user
ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
    && chmod -R u+rwx $HOME \
    && chown -R user:user $HOME

# switch back to user
WORKDIR $HOME

RUN apt-get update && \
      apt-get -y install sudo libgmp3-dev

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

RUN apt-get install -y python python-dev ipython python-pip libatlas-base-dev gfortran \
 python-glpk glpk-utils

RUN python -m pip install --upgrade pip

RUN pip install cmake

RUN pip install numpy scipy

RUN pip install cvxpy

USER docker
CMD /bin/bash
