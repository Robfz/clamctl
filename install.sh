#!/bin/bash
# Installs the latest clamctl release:
#   curl -fsSL https://github.com/Robfz/clamctl/releases/latest/download/install.sh | sudo bash
set -euo pipefail

main() {
  [[ $EUID -eq 0 ]] || { echo "run with sudo: curl -fsSL <url> | sudo bash" >&2; exit 1; }
  local tmp
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' EXIT
  curl -fsSL https://github.com/Robfz/clamctl/releases/latest/download/clamctl -o "$tmp"
  bash "$tmp" install
}

# Called on the last line so a truncated download runs nothing.
main
