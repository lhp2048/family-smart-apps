#!/usr/bin/env bash
# Linux: stop systemd user service or kill port listener
set -euo pipefail

SERVICE_NAME="family-smart-apps-web"
PORT="${PORT:-18027}"

if systemctl --user is-active "${SERVICE_NAME}.service" >/dev/null 2>&1; then
  systemctl --user stop "${SERVICE_NAME}.service"
  echo "stopped systemd service: ${SERVICE_NAME}"
  exit 0
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
