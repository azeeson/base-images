FROM --platform=${BUILDPLATFORM} alpine:3.15

LABEL maintainer="Azeeson <azeeson@gmail.com>"

ARG TARGETPLATFORM
ARG HUGO_VERSION=0.95.0

ENV LANG=C.UTF-8

RUN \
    case ${TARGETPLATFORM} in \
         "linux/amd64")  HUGO_ARCH=64bit  ;; \
         "linux/arm64")  HUGO_ARCH=ARM64  ;; \
    esac \
    && apk update \
    && rm -rf /var/cache/apk/* \
    && mkdir /usr/local/hugo \
    && wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz \
        -O /usr/local/hugo/hugo.tar.gz \
    && tar xzf /usr/local/hugo/hugo.tar.gz -C /usr/local/hugo/ \
    && ln -s /usr/local/hugo/hugo /usr/local/bin/hugo \
    && rm /usr/local/hugo/hugo.tar.gz

WORKDIR /data
