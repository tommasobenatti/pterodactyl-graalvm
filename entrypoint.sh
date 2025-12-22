#!/bin/bash

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

#System variables
clear
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Switch to the container's working directory
cd /home/container || exit 1

# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
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
echo -e "${YELLOW}Java Version: ${RED} $(java -version) ${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}
