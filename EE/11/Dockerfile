# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java
# Minimum Panel Version: 1.7.0
# ----------------------------------
FROM debian:trixie-slim

ARG JAVA_VERSION=11
ARG GRAALVM_SHA256

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
  && rm -rf /var/lib/apt/lists/*

RUN --mount=from=graalvm,target=/mnt/graalvm \
  test "${#GRAALVM_SHA256}" -eq 64 \
  && printf '%s  %s\n' "${GRAALVM_SHA256}" /mnt/graalvm/graalvm.tar.gz | sha256sum -c --strict - \
  && mkdir -p /opt/java/graalvm \
  && tar -xzf /mnt/graalvm/graalvm.tar.gz -C /opt/java/graalvm --strip-components=1 \
  && grep -q "^JAVA_VERSION=\"${JAVA_VERSION}\." /opt/java/graalvm/release

ENV JAVA_HOME=/opt/java/graalvm \
    PATH="/opt/java/graalvm/bin:$PATH"

# Step 2 - add pterodactyl stuff
RUN useradd -d /home/container -m container

USER        container
ENV         USER=container HOME=/home/container

WORKDIR     /home/container

COPY entrypoint.sh /entrypoint.sh

CMD         ["/bin/bash", "/entrypoint.sh"]
