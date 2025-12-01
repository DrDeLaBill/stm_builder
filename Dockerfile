ARG ALPINE_VERSION=3.20
FROM alpine:${ALPINE_VERSION} AS builder

ARG ARM_EABI_GCC_VERSION=11.3.1-1.1
ARG ARM_EABI_GCC_PACKAGE=xpack-arm-none-eabi-gcc-${ARM_EABI_GCC_VERSION}

ENV APP_ROOT=/app
ENV SRC_ROOT=${APP_ROOT}/src
ENV BUILD_ROOT=${APP_ROOT}/builder

RUN mkdir -p ${APP_ROOT} ${SRC_ROOT} ${BUILD_ROOT} /opt

WORKDIR ${APP_ROOT}

RUN apk add --no-cache --virtual .build-deps ca-certificates wget tar perl && \
    apk add --no-cache cmake make gcompat bash && \
    update-ca-certificates && \
    set -eux; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
      x86_64) XPACK_ARCH=linux-x64 ;; \
      aarch64) XPACK_ARCH=linux-arm64 ;; \
      armv7*|armv7l) XPACK_ARCH=linux-armv7 ;; \
      i?86) XPACK_ARCH=linux-x86 ;; \
      *) XPACK_ARCH=linux-x64 ;; \
    esac; \
    echo "Detected host arch: ${ARCH} -> using xpack suffix: ${XPACK_ARCH}"; \
    XPACK_URL="https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v${ARM_EABI_GCC_VERSION}/${ARM_EABI_GCC_PACKAGE}-${XPACK_ARCH}.tar.gz"; \
    echo "Downloading ${XPACK_URL}"; \
    wget -q -O /tmp/arm-none-eabi-gcc.tar.gz "${XPACK_URL}" || (echo "FAILED to download ${XPACK_URL}" && false); \
    tar -C /opt -xzf /tmp/arm-none-eabi-gcc.tar.gz; \
    rm -f /tmp/arm-none-eabi-gcc.tar.gz && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*

RUN ln -s /opt/${ARM_EABI_GCC_PACKAGE}/bin/arm-none-eabi-g++ /usr/local/bin/arm-none-eabi-g++ && \
    ln -s /opt/${ARM_EABI_GCC_PACKAGE}/bin/arm-none-eabi-gcc /usr/local/bin/arm-none-eabi-gcc && \
    ln -s /opt/${ARM_EABI_GCC_PACKAGE}/bin/arm-none-eabi-gdb /usr/local/bin/arm-none-eabi-gdb && \
    ln -s /opt/${ARM_EABI_GCC_PACKAGE}/bin/arm-none-eabi-size /usr/local/bin/arm-none-eabi-size && \
    ln -s /opt/${ARM_EABI_GCC_PACKAGE}/bin/arm-none-eabi-objcopy /usr/local/bin/arm-none-eabi-objcopy

ADD cmake/CMakeLists.txt ${APP_ROOT}/CMakeLists.txt
ADD cmake/search.cmake ${APP_ROOT}/search.cmake
ADD versions.sh ${APP_ROOT}/versions.sh

RUN chmod +x ${APP_ROOT}/versions.sh && ${APP_ROOT}/versions.sh