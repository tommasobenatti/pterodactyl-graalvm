# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
  FROM debian:trixie-slim

  ARG TARGETPLATFORM
  ARG JAVA_VERSION=25.5.5.0.3
  ARG BUILD_VERSION=25i5-25.0.5.0.3
  LABEL maintainer="Tommaso Benatti <tommaso.benatti@outlook.com>"

  ENV DEBIAN_FRONTEND=noninteractive

  # Default to UTF-8 file.encoding
  ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

  RUN apt-get update -y \
    && apt-get install -y --no-install-recommends bash coreutils sed unzip \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        curl \
        fontconfig \
        git \
        gnupg2 \
        iproute2 \
        jq \
        java-common \
        locales \
        openssl \
        procps \
        sqlite3 \
        tar \
        tzdata \
        wget \
        libfreetype6 \
        build-essential \
        zlib1g-dev \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && case ${TARGETPLATFORM} in \
           "linux/amd64")  ARCH=x64  ;; \
           "linux/arm64")  ARCH=aarch64  ;; \
        *) echo "Unsupported TARGETPLATFORM: ${TARGETPLATFORM}" >&2; exit 1 ;; \
      esac \
    && GRAALVM_URL="https://github.com/graalvm/graalvm-ce-builds/releases/download/graal-${JAVA_VERSION}/graalvm-community-jdk-${BUILD_VERSION}_linux-${ARCH}_bin.tar.gz" \
    && curl --proto "=https" --proto-redir "=https" --retry 3 --retry-all-errors --connect-timeout 15 --max-time 600 -Lfso /tmp/graalvm.tar.gz "${GRAALVM_URL}" \
    && curl --proto "=https" --proto-redir "=https" --retry 3 --retry-all-errors --connect-timeout 15 --max-time 120 -Lfso /tmp/graalvm.sha256 "${GRAALVM_URL}.sha256" \
    && printf '%s  %s\n' "$(awk '{print $1}' /tmp/graalvm.sha256)" /tmp/graalvm.tar.gz | sha256sum -c - \
    && mkdir -p /opt/java/graalvm \
    && cd /opt/java/graalvm \
    && tar -xf /tmp/graalvm.tar.gz --strip-components=1 \
    && export PATH="/opt/java/graalvm/bin:$PATH" \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/graalvm.tar.gz /tmp/graalvm.sha256

  ENV JAVA_HOME=/opt/java/graalvm \
      PATH="/opt/java/graalvm/bin:$PATH"

  # Step 2 - add pterodactyl stuff
  RUN useradd -d /home/container -m container

  USER        container
  ENV         USER=container HOME=/home/container

  WORKDIR     /home/container

  COPY entrypoint.sh /entrypoint.sh

  CMD         ["/bin/bash", "/entrypoint.sh"]
