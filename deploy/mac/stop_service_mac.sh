#!/usr/bin/env bash
# macOS: stop launchd service or kill port listener
set -euo pipefail

LABEL="com.family.smart.apps-web"
PLIST_DEST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
PORT="${PORT:-18027}"

launchctl_user_domain() {
  echo "gui/$(id -u)"
}

domain="$(launchctl_user_domain)"
if [[ -f "${PLIST_DEST}" ]] && launchctl print "${domain}/${LABEL}" &>/dev/null; then
  launchctl bootout "${domain}" "${PLIST_DEST}" 2>/dev/null || true
  echo "stopped launchd service: ${LABEL}"
fi

pids="$(lsof -ti tcp:"${PORT}" 2>/dev/null || true)"
if [[ -n "${pids}" ]]; then
  kill ${pids} 2>/dev/null || true
  sleep 1
  pids="$(lsof -ti tcp:"${PORT}" 2>/dev/null || true)"
  [[ -n "${pids}" ]] && kill -9 ${pids} 2>/dev/null || true
  echo "stopped listener on port ${PORT}"
else
  echo "no listener on port ${PORT}"
fi
