#!/bin/bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "run with sudo" >&2; exit 1; }

LABEL=com.robfz.clamctl

launchctl bootout "system/$LABEL" 2>/dev/null || true
rm -f "/Library/LaunchDaemons/$LABEL.plist" /usr/local/bin/clamctl
rm -rf /var/db/clamctl
# The daemon resets this on stop; repeated here in case it wasn't running.
pmset -a disablesleep 0
echo "uninstalled; disablesleep=0"
