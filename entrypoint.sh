#!/bin/bash
set -Eeuo pipefail

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# System variables
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Switch to the container's working directory
cd /home/container || exit 1

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}' || true)
export INTERNAL_IP

# 1) If TZ is provided by Wings/Docker, use it.
# 2) Else try derive from /etc/localtime symlink (common when host mounts it).
# 3) Else fallback to UTC.

if [ -n "${TZ:-}" ]; then
  export TZ
else
  TZ_DERIVED=""
  if [ -L /etc/localtime ]; then
    LINK="$(readlink /etc/localtime 2>/dev/null || true)"
    case "$LINK" in
      */usr/share/zoneinfo/*) TZ_DERIVED="${LINK##*/usr/share/zoneinfo/}" ;;
      */zoneinfo/*)           TZ_DERIVED="${LINK##*/zoneinfo/}" ;;
    esac
  fi

  TZ="${TZ_DERIVED:-UTC}"
  export TZ
fi

# For display purposes only (avoid failing if file doesn't exist)
TZ_DISPLAY="${TZ}"
if [ -f /etc/timezone ]; then
  TZ_FILE="$(cat /etc/timezone 2>/dev/null || true)"
  [ -n "$TZ_FILE" ] && TZ_DISPLAY="$TZ_FILE"
fi

# system informations
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${RED}Java GraalVM Image by tommaso.benatti@mcexp.it${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Running on Debian: ${RED} $(cat /etc/debian_version)${NC}"
echo -e "${YELLOW}Current timezone: ${RED} ${TZ_DISPLAY}${NC}"
echo -e "${YELLOW}Java Version:${NC}"
java -version
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Expand Pterodactyl {{VARIABLE}} placeholders directly from the environment.
# This preserves quotes and compound commands without the destructive word splitting
# caused by eval + exec env.
PARSED=${STARTUP}
EXPANSIONS=0
while [[ ${PARSED} =~ \{\{([A-Za-z_][A-Za-z0-9_]*)\}\} ]]; do
  ((EXPANSIONS += 1))
  if ((EXPANSIONS > 100)); then
    echo "Too many nested Pterodactyl variable expansions in STARTUP" >&2
    exit 1
  fi
  VARIABLE=${BASH_REMATCH[1]}
  VALUE=${!VARIABLE-}
  PARSED=${PARSED//\{\{${VARIABLE}\}\}/${VALUE}}
done

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
exec /bin/bash -c "${PARSED}"
