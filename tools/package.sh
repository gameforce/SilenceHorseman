#!/usr/bin/env bash
# Builds dist/SilenceHorseman-<version>.zip with the addon folder inside it.
set -euo pipefail
cd "$(dirname "$0")/.."
version=$(sed -n 's/^## Version: *//p' SilenceHorseman.toc | tr -d '\r')
stage=$(mktemp -d)
mkdir -p "$stage/SilenceHorseman" dist
cp SilenceHorseman.toc SilenceHorseman.lua icon.tga LICENSE "$stage/SilenceHorseman/"
out="dist/SilenceHorseman-$version.zip"
rm -f "$out"
(cd "$stage" && zip -qr - SilenceHorseman) > "$out"
rm -r "$stage"
unzip -l "$out"
