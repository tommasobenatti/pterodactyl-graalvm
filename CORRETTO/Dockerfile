# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Amazon Corretto
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM debian:trixie-slim

ARG TARGETPLATFORM
ARG JAVA_VERSION=25

LABEL maintainer="Tommaso Benatti <tommaso.benatti@outlook.com>" \
      org.opencontainers.image.source="https://github.com/tommasobenatti/pterodactyl-graalvm" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        coreutils \
        curl \
        fontconfig \
        git \
        iproute2 \
        jq \
        libfreetype6 \
        libstdc++6 \
        locales \
        lsof \
        openssl \
        procps \
        sqlite3 \
        tar \
        tzdata \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && case "${TARGETPLATFORM}" in \
         "linux/amd64") ARCH=x64 ;; \
         "linux/arm64") ARCH=aarch64 ;; \
         *) echo "Unsupported TARGETPLATFORM: ${TARGETPLATFORM}" >&2; exit 1 ;; \
       esac \
    && CORRETTO_FILE="amazon-corretto-${JAVA_VERSION}-${ARCH}-linux-jdk.tar.gz" \
    && CORRETTO_URL="https://corretto.aws/downloads/latest/${CORRETTO_FILE}" \
    && CORRETTO_SHA_URL="https://corretto.aws/downloads/latest_sha256/${CORRETTO_FILE}" \
    && curl --retry 3 --retry-all-errors -Lfso /tmp/corretto.tar.gz "${CORRETTO_URL}" \
    && curl --retry 3 --retry-all-errors -Lfso /tmp/corretto.sha256 "${CORRETTO_SHA_URL}" \
    && printf '%s  %s\n' "$(tr -d '[:space:]' < /tmp/corretto.sha256)" /tmp/corretto.tar.gz | sha256sum -c - \
    && mkdir -p /opt/java/corretto \
    && tar -xzf /tmp/corretto.tar.gz -C /opt/java/corretto --strip-components=1 \
    && useradd -d /home/container -m container \
    && rm -rf /var/lib/apt/lists/* /tmp/corretto.tar.gz /tmp/corretto.sha256

ENV JAVA_HOME=/opt/java/corretto \
    PATH="/opt/java/corretto/bin:${PATH}"

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
