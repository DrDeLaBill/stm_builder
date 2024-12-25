FROM debian:trixie-20240926 AS builder

# ENV PATH="${PATH}:/usr/bin"

RUN CURR_PATH=$(pwd)

RUN apt-get update
RUN apt-get install -y wget

RUN wget -O arm-none-eabi-gcc.tar.gz "https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v11.3.1-1.1/xpack-arm-none-eabi-gcc-11.3.1-1.1-linux-x64.tar.gz"
RUN tar -xvf arm-none-eabi-gcc.tar.gz
RUN rm arm-none-eabi-gcc.tar.gz
RUN ln -s $CURR_PATH/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-g++ /usr/bin/arm-none-eabi-g++
RUN ln -s $CURR_PATH/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-gcc /usr/bin/arm-none-eabi-gcc
RUN ln -s $CURR_PATH/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-gdb /usr/bin/arm-none-eabi-gdb
RUN ln -s $CURR_PATH/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-size /usr/bin/arm-none-eabi-size
RUN ln -s $CURR_PATH/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-objcopy /usr/bin/arm-none-eabi-objcopy
RUN arm-none-eabi-gcc --version
RUN arm-none-eabi-g++ --version
RUN arm-none-eabi-gdb --version
RUN arm-none-eabi-size --version
RUN arm-none-eabi-objcopy --version

RUN wget https://cmake.org/files/v3.26/cmake-3.26.0-linux-x86_64.tar.gz 
RUN tar xzf cmake-3.26.0-linux-x86_64.tar.gz
RUN rm -rf cmake-3.26.0-linux-x86_64.tar.gz
RUN cd cmake-3.26.0-linux-x86_64
RUN apt-get install
RUN ln -s $CURR_PATH/cmake-3.26.0-linux-x86_64/bin/cmake /usr/bin/cmake
RUN cmake --version

RUN ls -al
