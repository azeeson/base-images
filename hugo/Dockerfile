FROM alpine:3.16

LABEL maintainer="Azeeson <azeeson@gmail.com>"

ARG TARGETOS
ARG TARGETARCH
ARG HUGO_VERSION=0.108.0

ENV LANG=C.UTF-8

RUN set -x \
    && apk update \
    && rm -rf /var/cache/apk/* \
    && mkdir /usr/local/hugo \
    && wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_${TARGETOS}-${TARGETARCH}.tar.gz \
        -O /usr/local/hugo/hugo.tar.gz \
    && tar xzf /usr/local/hugo/hugo.tar.gz -C /usr/local/hugo/ \
    && ln -s /usr/local/hugo/hugo /usr/local/bin/hugo \
    && rm /usr/local/hugo/hugo.tar.gz

WORKDIR /data
