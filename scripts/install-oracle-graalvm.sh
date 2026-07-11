#!/usr/bin/env bash
set -euo pipefail

JAVA_VERSION=${1:?Java major version is required}
ARCH=${2:?Architecture is required}

case ${ARCH} in
  x64|aarch64) ;;
  *) echo "Unsupported GraalVM architecture: ${ARCH}" >&2; exit 1 ;;
esac

ARCHIVE="graalvm-jdk-${JAVA_VERSION}_linux-${ARCH}_bin.tar.gz"
URL="https://download.oracle.com/graalvm/${JAVA_VERSION}/latest/${ARCHIVE}"

curl --retry 3 --retry-all-errors -Lfso /tmp/graalvm.tar.gz "${URL}"
curl --retry 3 --retry-all-errors -Lfso /tmp/graalvm.sha256 "${URL}.sha256"

EXPECTED_SHA=$(awk '{print $1}' /tmp/graalvm.sha256)
if [[ ! ${EXPECTED_SHA} =~ ^[0-9a-fA-F]{64}$ ]]; then
  echo "Invalid SHA-256 response for ${ARCHIVE}" >&2
  exit 1
fi

printf '%s  %s\n' "${EXPECTED_SHA}" /tmp/graalvm.tar.gz | sha256sum -c -
rm -f /tmp/graalvm.sha256
