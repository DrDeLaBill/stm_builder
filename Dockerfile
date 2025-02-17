FROM debian:trixie-20250113-slim AS builder

ARG BUILD_MIRROR_URL=deb.debian.org

ENV APP_ROOT=/app
ENV SRC_ROOT=$APP_ROOT/src
ENV CMAKE_PACKAGE=cmake-3.26.0-linux-x86_64
ENV GCC_PACKAGE=xpack-arm-none-eabi-gcc-11.3.1-1.1

RUN mkdir -p $APP_ROOT $SRC_ROOT

WORKDIR $APP_ROOT

RUN sed -i "s/deb.debian.org/$BUILD_MIRROR_URL/g" /etc/apt/sources.list.d/debian.sources

RUN apt-get update > /dev/null \
 && apt-get install -qq -y wget build-essential > /dev/null

RUN wget -q -O arm-none-eabi-gcc.tar.gz "https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v11.3.1-1.1/$GCC_PACKAGE-linux-x64.tar.gz" \
 && tar -xf arm-none-eabi-gcc.tar.gz \
 && rm arm-none-eabi-gcc.tar.gz

RUN ln -s $APP_ROOT/$GCC_PACKAGE/bin/arm-none-eabi-g++ /usr/bin/arm-none-eabi-g++ \
 && ln -s $APP_ROOT/$GCC_PACKAGE/bin/arm-none-eabi-gcc /usr/bin/arm-none-eabi-gcc \
 && ln -s $APP_ROOT/$GCC_PACKAGE/bin/arm-none-eabi-gdb /usr/bin/arm-none-eabi-gdb \
 && ln -s $APP_ROOT/$GCC_PACKAGE/bin/arm-none-eabi-size /usr/bin/arm-none-eabi-size \
 && ln -s $APP_ROOT/$GCC_PACKAGE/bin/arm-none-eabi-objcopy /usr/bin/arm-none-eabi-objcopy


RUN wget -q -O cmake.tar.gz "https://cmake.org/files/v3.26/$CMAKE_PACKAGE.tar.gz" \
 && tar -xf cmake.tar.gz \
 && rm -rf cmake.tar.gz

RUN ln -s $APP_ROOT/$CMAKE_PACKAGE/bin/cmake /usr/bin/cmake

ADD cmake/CMakeLists.txt $APP_ROOT/CMakeLists.txt
ADD cmake/search.cmake $APP_ROOT/search.cmake
ADD versions.sh $APP_ROOT/versions.sh
RUN chmod a+x $APP_ROOT/versions.sh \
 && $APP_ROOT/versions.sh