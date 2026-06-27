#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="family-smart-apps-web"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PORT="${PORT:-18027}"
DO_FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) DO_FORCE=1; shift ;;
    --port)  PORT="${2:-18027}"; shift 2 ;;
    *) shift ;;
  esac
done

kill_port() {
  local pids
  pids="$(lsof -ti tcp:"${PORT}" 2>/dev/null || true)"
  [[ -n "${pids}" ]] && kill ${pids} 2>/dev/null || true
}

if systemctl --user is-active "${SERVICE_NAME}.service" >/dev/null 2>&1; then
  if [[ "${DO_FORCE}" -eq 1 ]]; then
    systemctl --user restart "${SERVICE_NAME}.service"
  else
    echo "already running (systemd): http://127.0.0.1:${PORT}"
    exit 0
  fi
else
  if [[ "${DO_FORCE}" -eq 1 ]]; then kill_port; fi
  if [[ -x "${SCRIPT_DIR}/run_web.sh" ]]; then
    nohup bash "${SCRIPT_DIR}/run_web.sh" >/dev/null 2>&1 &
    disown $! 2>/dev/null || true
  fi
fi

sleep 1
curl -sf "http://127.0.0.1:${PORT}/" >/dev/null && echo "OK: http://127.0.0.1:${PORT}"
