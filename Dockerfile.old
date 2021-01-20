FROM ubuntu:18.04

ENV RISCV_TOOLCHAIN_PATH=/opt/riscv-gnu-toolchain
ENV LLVM_PREFIX=/opt/llvm
ENV POCL_CC_PATH=/opt/pocl/cc
ENV POCL_RT_PATH=/opt/pocl/rt
ENV VORTEX_HOME=/opt/vortex
ENV VORTEX_DRIVER_INC=${VORTEX_HOME}/driver/include
ENV VORTEX_DRIVER_LIB=${VORTEX_HOME}/driver/stub/libvortex.so
ENV VORTEX_RUNTIME_PATH=${VORTEX_HOME}/runtime

# install dependencies
RUN apt-get update && apt-get -y install \
    binutils build-essential libtool texinfo \
    gzip zip unzip patchutils curl git \
    make cmake ninja-build automake bison flex gperf \
    grep sed gawk python bc \
    zlib1g-dev libexpat1-dev libmpc-dev \
    libglib2.0-dev libfdt-dev libpixman-1-dev \
    perl python3 libfl2 libfl-dev zlibc zlib1g autoconf

# install GNU RISC-V Tools
RUN git clone https://github.com/riscv/riscv-gnu-toolchain /tmp/riscv-gnu-toolchain; \
    cd /tmp/riscv-gnu-toolchain; \
    git submodule update --init --recursive
RUN cd /tmp/riscv-gnu-toolchain; \
    mkdir build; \
    cd build; \
    ../configure --prefix=$RISCV_TOOLCHAIN_PATH --with-arch=rv32imf --with-abi=ilp32f
RUN cd /tmp/riscv-gnu-toolchain/build; \
    make -j4; \
    make -j4 build-qemu; \
    rm -rf /tmp/riscv-gnu-toolchain

# install Verilator
RUN git clone https://github.com/verilator/verilator /tmp/verilator; \
    unset VERILATOR_ROOT; \
    cd /tmp/verilator; \
    git checkout stable; \
    autoconf; \
    ./configure; \
    make -j4; \
    make install

# install LLVM
RUN git clone -b release/10.x https://github.com/llvm/llvm-project.git /tmp/llvm-project
# patch LLVMBuild
COPY ./patches/LLVMBuild.patch /LLVMBuild.patch
RUN cd /tmp/llvm-project/; \
    git apply /LLVMBuild.patch
RUN mkdir -p /tmp/llvm-project/build; \
    cd /tmp/llvm-project/build; \
    cmake -G Ninja -DLLVM_ENABLE_PROJECTS="clang" -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True  -DCMAKE_INSTALL_PREFIX=$LLVM_PREFIX -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=True -DDEFAULT_SYSROOT=$RISC_GNU_TOOLS_PATH/riscv32-unknown-elf -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" -DLLVM_TARGETS_TO_BUILD="RISCV" ../llvm; \
    cmake --build . --target install -- -j6; \
    rm -rf /tmp/llvm-project

# install Vortex
COPY hw ${VORTEX_HOME}
COPY runtime ${VORTEX_HOME}
COPY driver ${VORTEX_HOME}
RUN cd ${VORTEX_HOME}; \
    git submodule init; \
    git submodule update --recursive; \
    cd hw/rtl/fp_cores/fpnew; \
    git submodule init; \
    git submodule update --recursive;
RUN cd ${VORTEX_HOME}; \
    make -C hw build_config; \
    make -C runtime -j ; \
    make -C driver/stub -j
RUN rm -rf ${VORTEX_HOME}

# install POCL
RUN git clone https://github.com/vortexgpgpu/pocl.git /tmp/pocl
RUN mkdir -p /tmp/pocl/build_cc; \
    cd /tmp/pocl/build_cc; \
    cmake -G Ninja -DCMAKE_INSTALL_PREFIX=$POCL_CC_PATH -DOCS_AVAILABLE=ON -DWITH_LLVM_CONFIG=$LLVM_PREFIX/bin/llvm-config -DENABLE_VORTEX=ON -DVORTEX_RUNTIME_PATH=$VORTEX_RUNTIME_PATH -DVORTEX_DRIVER_INC=$VORTEX_DRIVER_INC -DVORTEX_DRIVER_LIB=$VORTEX_DRIVER_LIB -DBUILD_TESTS=OFF -DPOCL_DEBUG_MESSAGES=ON ..; \
    cmake --build . --target install
RUN mkdir -p /tmp/pocl/build_rt; \
    cd /tmp/pocl/build_rt; \
    cmake -G Ninja -DCMAKE_INSTALL_PREFIX=$POCL_RT_PATH -DOCS_AVAILABLE=OFF -DHOST_DEVICE_BUILD_HASH=riscv32-unknown-unknown-elf -DENABLE_VORTEX=ON -DVORTEX_RUNTIME_PATH=$VORTEX_RUNTIME_PATH -DVORTEX_DRIVER_INC=$VORTEX_DRIVER_INC -DVORTEX_DRIVER_LIB=$VORTEX_DRIVER_LIB -DBUILD_TESTS=OFF -DPOCL_DEBUG_MESSAGES=ON ..; \
    cmake --build . --target install; \
    rm -rf /tmp/pocl

