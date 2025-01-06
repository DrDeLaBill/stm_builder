FROM debian:trixie-20240926 AS builder

ENV APP_ROOT=/app

RUN mkdir -p $APP_ROOT $APP_ROOT/src
WORKDIR $APP_ROOT

RUN apt-get update \
 && apt-get install -y wget

RUN wget -O arm-none-eabi-gcc.tar.gz "https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v11.3.1-1.1/xpack-arm-none-eabi-gcc-11.3.1-1.1-linux-x64.tar.gz" \
 && tar -xvf arm-none-eabi-gcc.tar.gz \
 && rm arm-none-eabi-gcc.tar.gz

RUN ln -s $APP_ROOT/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-g++ /usr/bin/arm-none-eabi-g++ \
 && ln -s $APP_ROOT/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-gcc /usr/bin/arm-none-eabi-gcc \
 && ln -s $APP_ROOT/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-gdb /usr/bin/arm-none-eabi-gdb \
 && ln -s $APP_ROOT/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-size /usr/bin/arm-none-eabi-size \
 && ln -s $APP_ROOT/xpack-arm-none-eabi-gcc-11.3.1-1.1/bin/arm-none-eabi-objcopy /usr/bin/arm-none-eabi-objcopy


RUN wget "https://cmake.org/files/v3.26/cmake-3.26.0-linux-x86_64.tar.gz" \
 && tar xzf cmake-3.26.0-linux-x86_64.tar.gz \
 && rm -rf cmake-3.26.0-linux-x86_64.tar.gz

RUN ln -s $APP_ROOT/cmake-3.26.0-linux-x86_64/bin/cmake /usr/bin/cmake

ADD versions.sh $APP_ROOT/versions.sh
RUN chmod a+x $APP_ROOT/versions.sh \
 && $APP_ROOT/versions.sh
