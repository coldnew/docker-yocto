# This dockerfile uses the ubuntu image
# VERSION 0 - EDITION 1
# Author:  Yen-Chin, Lee <yenchin@weintek.com>
# Command format: Instruction [arguments / command] ..

FROM ubuntu:24.04
MAINTAINER Yen-Chin, Lee, coldnew.tw@gmail.com

# Disable interactive functions
ENV DEBIAN_FRONTEND noninteractive

# https://askubuntu.com/questions/1513927/ubuntu-24-04-docker-images-now-includes-user-ubuntu-with-uid-gid-1000
# remove default uid 1000 user 
RUN userdel -r ubuntu

# Add 32bit package in package list
RUN dpkg --add-architecture i386
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list &&  \
    sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources

## Install requred packages:
# http://www.yoctoproject.org/docs/current/ref-manual/ref-manual.html
RUN apt-get update -y && \
    apt-get -y build-dep qemu 

# Essentials
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat tar python3 python3-pip python3-pexpect \
     debianutils iputils-ping python3-git python3-jinja2 libsdl1.2-dev \
     xterm cpio

# Graphical and Eclipse Plug-In Extras
RUN apt-get install -y libsdl1.2-dev xterm

# Documentation
RUN apt-get install -y make xsltproc docbook-utils fop dblatex xmlto

# OpenEmbedded Self-Test
#RUN apt-get install -y python-git

# Extra package for build with NXP's images
RUN apt-get install -y \
    sed cvs subversion coreutils texi2html \
    help2man  gcc g++ \
    desktop-file-utils mercurial \
    autoconf automake groff curl lzop asciidoc u-boot-tools busybox vim

# Extra package for Xilinx PetaLinux
# RUN apt-get install -y xvfb libtool libncurses5-dev libssl-dev zlib1g-dev:i386 tftpd

# Install repo tool for some bsp case, like NXP's yocto
RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
RUN chmod a+x /usr/bin/repo

# Install Java
#RUN \
#  echo oracle-java11-installer shared/accepted-oracle-license-v1-2 select true | debconf-set-selections && \
#  apt-get install -y software-properties-common && \
#  add-apt-repository -y ppa:linuxuprising/java && \
#  apt-get update && \
#  apt-get install -y oracle-java11-installer-local && \
#  rm -rf /var/lib/apt/lists/* && \
#  rm -rf /var/cache/oracle-jdk11-installer-local

# Set the locale, else yocto will complain
RUN apt-get install locales -y
RUN locale-gen en_US.UTF-8 && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# make /bin/sh symlink to bash instead of dash
# Xilinx's petalinux need this
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# default workdir is /yocto
WORKDIR /yocto

# Add entry point, we use entrypoint.sh to mapping host user to
# container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
