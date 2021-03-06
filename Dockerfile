FROM ubuntu:18.04

RUN apt-get update; apt-get -y install \
	binutils build-essential libtool texinfo \
	gzip zip unzip patchutils curl git \
	make cmake ninja-build automake bison flex gperf \
	grep sed gawk python bc \
	zlib1g-dev libexpat1-dev libmpc-dev \
	libglib2.0-dev libfdt-dev libpixman-1-dev \
	wget

COPY ci/toolchain_install.sh /
RUN /toolchain_install.sh -all

ENV VERILATOR_ROOT=/opt/verilator
ENV PATH="/opt/verilator/bin:${PATH}"