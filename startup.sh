#!/usr/bin/env bash
set -euo pipefail

REPO="Winds-Studio/Leaf"
UA="pelican-egg-leaf"

SERVER_JARFILE="${SERVER_JARFILE:-server.jar}"
MINECRAFT_VERSION="${MINECRAFT_VERSION:-latest}"
BUILD_NUMBER="${BUILD_NUMBER:-latest}"
AUTO_UPDATE_RAW="${AUTO_UPDATE:-false}"

is_true() {
  case "${1,,}" in
    1|true|yes|y|on|enabled) return 0 ;;
    *) return 1 ;;
  esac
}

get_api_url() {
  if [[ -z "${MINECRAFT_VERSION}" || "${MINECRAFT_VERSION}" == "latest" ]]; then
    echo "https://api.github.com/repos/${REPO}/releases/latest"
  else
    echo "https://api.github.com/repos/${REPO}/releases/tags/ver-${MINECRAFT_VERSION}"
  fi
}

extract_tag_name() {
  # first tag_name
  tr '\n' ' ' | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' | head -n 1
}

extract_download_url() {
  local resolved_version="$1"
  local json_one_line
  json_one_line=$(tr '\n' ' ')

  if [[ -z "${BUILD_NUMBER}" || "${BUILD_NUMBER}" == "latest" ]]; then
    # leaf-<version>-<digits>.jar
    echo "${json_one_line}" | sed -nE "s/.*\"browser_download_url\"[[:space:]]*:[[:space:]]*\"([^\"]*\\/leaf-${resolved_version}-[0-9]+\\.jar)\".*/\\1/p" | head -n 1
  else
    # leaf-<version>-<build>.jar
    echo "${json_one_line}" | sed -nE "s/.*\"browser_download_url\"[[:space:]]*:[[:space:]]*\"([^\"]*\\/leaf-${resolved_version}-${BUILD_NUMBER}\\.jar)\".*/\\1/p" | head -n 1
  fi
}

maybe_update_jar() {
  if ! is_true "${AUTO_UPDATE_RAW}"; then
    echo "[Leaf] Auto-updater disabled (AUTO_UPDATE=${AUTO_UPDATE_RAW})"
    return 0
  fi

  local api_url release_json tag resolved_version download_url tmp_jar

  api_url="$(get_api_url)"
  echo "[Leaf] Auto-updater enabled (AUTO_UPDATE=${AUTO_UPDATE_RAW})"
  echo "[Leaf] Checking: ${api_url}"

  release_json="$(curl -fsSL -H "Accept: application/vnd.github+json" -H "User-Agent: ${UA}" "${api_url}")"

  tag="$(printf '%s' "${release_json}" | extract_tag_name)"
  if [[ -z "${tag}" ]]; then
    echo "[Leaf] ERROR: Could not parse tag_name (rate limit? invalid tag?)"
    exit 1
  fi

  resolved_version="${tag#ver-}"
  echo "[Leaf] Resolved version: ${resolved_version} (tag ${tag})"

  download_url="$(printf '%s' "${release_json}" | extract_download_url "${resolved_version}")"
  if [[ -z "${download_url}" ]]; then
    echo "[Leaf] ERROR: Could not find matching jar in release assets"
    echo "[Leaf] Expected leaf-${resolved_version}-${BUILD_NUMBER}.jar (or latest numeric build)."
    exit 1
  fi

  echo "[Leaf] Downloading: ${download_url}"
  tmp_jar="${SERVER_JARFILE}.new"
  curl -fsSL -L -o "${tmp_jar}" "${download_url}"

  if [[ -f "${SERVER_JARFILE}" ]]; then
    local old_sha new_sha
    old_sha="$(sha256sum "${SERVER_JARFILE}" | awk '{print $1}')"
    new_sha="$(sha256sum "${tmp_jar}" | awk '{print $1}')"

    if [[ "${old_sha}" == "${new_sha}" ]]; then
      echo "[Leaf] Already up-to-date"
      rm -f "${tmp_jar}"
      return 0
    fi

    echo "[Leaf] Update found, replacing jar"
    mv -f "${SERVER_JARFILE}" "${SERVER_JARFILE}.old" || true
  else
    echo "[Leaf] No existing jar, installing"
  fi

  mv -f "${tmp_jar}" "${SERVER_JARFILE}"
}

maybe_update_jar

exec java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar "${SERVER_JARFILE}"
