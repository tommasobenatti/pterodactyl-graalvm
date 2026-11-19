#!/usr/bin/env bash
set -euo pipefail

image=${1:?Image tag is required}
platforms=${2:?Comma-separated platforms are required}
IFS=, read -ra targets <<< "$platforms"
for platform in "${targets[@]}"; do
  docker run --rm --platform "$platform" --entrypoint /bin/bash "$image" -eu -c '
    test "$(id -u)" -ne 0
    test "$PWD" = /home/container
    for tool in bash curl jq sed sha256sum unzip java jar; do command -v "$tool"; done
    java -version
    printf "{\"ok\":true}" | jq -e .ok
    printf test | sha256sum
    mkdir /tmp/yolk-check
    printf test > /tmp/yolk-check/file
    jar cf /tmp/yolk-check.jar -C /tmp/yolk-check .
    unzip -tq /tmp/yolk-check.jar
  '
  docker run --rm --platform "$platform" \
    -e SERVER_PORT=25565 -e SERVER_MEMORY=1024 \
    -e STARTUP='test "{{HOME}}" = /home/container && test "{{SERVER_PORT}}:{{SERVER_MEMORY}}" = 25565:1024 && printf "Startup expansion OK\n"' "$image"
done
