#!/usr/bin/env bash
set -euo pipefail

JAVA_VERSION=${1:?Java major version is required}
ARCH=${2:?Architecture is required}
EA_RELEASE=${3:-}

case ${ARCH} in
  x64|aarch64) ;;
  *) echo "Unsupported GraalVM architecture: ${ARCH}" >&2; exit 1 ;;
esac

if [[ -n ${EA_RELEASE} ]]; then
  if [[ ! ${EA_RELEASE} =~ ^jdk-([0-9]+[ei][0-9]+-)?[0-9]+(\.[0-9]+)+-ea\.[0-9]+$ ]]; then
    echo "Invalid Oracle GraalVM Early Access release tag: ${EA_RELEASE}" >&2
    exit 1
  fi
  ARCHIVE="graalvm-${EA_RELEASE}_linux-${ARCH}_bin.tar.gz"
  URL="https://github.com/graalvm/oracle-graalvm-ea-builds/releases/download/${EA_RELEASE}/${ARCHIVE}"
else
  ARCHIVE="graalvm-jdk-${JAVA_VERSION}_linux-${ARCH}_bin.tar.gz"
  URL="https://download.oracle.com/graalvm/${JAVA_VERSION}/latest/${ARCHIVE}"
fi

DOWNLOAD_DIR=${TMPDIR:-/tmp}

curl --proto '=https' --proto-redir '=https' --retry 3 --retry-all-errors --connect-timeout 15 --max-time 600 -Lfso "${DOWNLOAD_DIR}/graalvm.tar.gz" "${URL}"
curl --proto '=https' --proto-redir '=https' --retry 3 --retry-all-errors --connect-timeout 15 --max-time 120 -Lfso "${DOWNLOAD_DIR}/graalvm.sha256" "${URL}.sha256"

EXPECTED_SHA=$(awk '{print $1}' "${DOWNLOAD_DIR}/graalvm.sha256")
if [[ ! ${EXPECTED_SHA} =~ ^[0-9a-fA-F]{64}$ ]]; then
  echo "Invalid SHA-256 response for ${ARCHIVE}" >&2
  exit 1
fi

printf '%s  %s\n' "${EXPECTED_SHA}" "${DOWNLOAD_DIR}/graalvm.tar.gz" | sha256sum -c -
rm -f "${DOWNLOAD_DIR}/graalvm.sha256"
