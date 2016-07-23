#!/bin/bash

# Pacman Sync
#
# I wanted a way to execute pacman with an external downloader such that all
# the required files are passed to the external downloader together. This
# allows the external downloader to:
#   a. Download multiple files in parallel
#   b. Reuse the TCP connection
#   c. Keep the DNS entries and connections cached
#
# These greatly reduce the time required for an upgrade.

set -e
set -o pipefail
set -u
# set -x

# This script *MUST* be run as root.
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

## Configurations

# TODO: Source these from pacman.conf or use alpm to provide this info

# Set the machine architecture here
arch="x86_64"

# Various path locations
DB_DIR="/var/lib/pacman/sync"
TMPDIR="$(mktemp -d)"
CACHE_DIR="/var/cache/pacman/pkg"

CORE_DATABASES=( testing core extra community-testing community )
OTHER_DATABASES=( http://bohoomil.com/repo/${arch}/infinality-bundle.db http://bohoomil.com/repo/fonts/infinality-bundle-fonts.db)

# Get the top server from the mirrorlist
# TODO: Extend script to allow for server failures
SERVER=$(grep -m 1 Server /etc/pacman.d/mirrorlist | awk '{print $3}')

declare -a DB_LIST_URL

for repo in "${CORE_DATABASES[@]}"; do
	R_URL=$(eval echo "$SERVER")
	DB_LIST_URL+=("${R_URL}/${repo}.db")
done

for repo in "${OTHER_DATABASES[@]}"; do
	DB_LIST_URL+=("$repo")
done

pushd "$TMPDIR" &> /dev/null
wget2 --progress=bar "${DB_LIST_URL[@]}"
popd &> /dev/null

mv "$TMPDIR/"* $DB_DIR/
rm -r "$TMPDIR"

pushd "$CACHE_DIR" &> /dev/null
_UPDATES=$(pacman -Sup | tail -n+2 | tr '\n' ' ')
echo "$_UPDATES"
if [[ ! -z $_UPDATES ]]; then
	wget2 --progress=bar $_UPDATES && pacman -Su
else
	echo "No Updates found"
fi
popd &> /dev/null
