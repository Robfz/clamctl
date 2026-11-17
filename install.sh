#!/bin/bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "run with sudo" >&2; exit 1; }
cd "$(dirname "$0")"

LABEL=com.robfz.clamctl
PLIST=/Library/LaunchDaemons/$LABEL.plist

launchctl bootout "system/$LABEL" 2>/dev/null || true
install -d /usr/local/bin
install -m 755 -o root -g wheel clamctl /usr/local/bin/clamctl
install -m 644 -o root -g wheel "$LABEL.plist" "$PLIST"
launchctl bootstrap system "$PLIST"
sleep 1
/usr/local/bin/clamctl status
