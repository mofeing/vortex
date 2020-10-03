FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ARG RISCV_TOOLCHAIN_PATH=/opt/riscv-gnu-toolchain

# install GNU RISC-V Tools dependencies
RUN apt-get update && apt-get -y install \
    binutils build-essential libtool texinfo \
    gzip zip unzip patchutils curl git \
    make cmake ninja-build automake bison flex gperf \
    grep sed gawk python bc \
    zlib1g-dev libexpat1-dev libmpc-dev \
    libglib2.0-dev libfdt-dev libpixman-1-dev \
    verilator

# install GNU RISC-V Tools dependencies
RUN git clone https://github.com/riscv/riscv-gnu-toolchain /tmp/riscv-gnu-toolchain \
    && cd /tmp/riscv-gnu-toolchain \
    && git submodule update --init --recursive
RUN cd /tmp/riscv-gnu-toolchain \
    && mkdir build \
    && cd build \
    && ../configure --prefix=$RISCV_TOOLCHAIN_PATH --with-arch=rv32im --with-abi=ilp32 \
    && VERBOSE=1 make -j4 \
    && VERBOSE=1 make -j4 build-qemu \
    && rm -rf /tmp/riscv-gnu-toolchain
