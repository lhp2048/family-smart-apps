#!/usr/bin/env bash
# Linux: start static web (used by systemd / manual)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

if [[ ! -f "${APP_ROOT}/index.html" ]]; then
  echo "error: index.html not found in ${APP_ROOT}" >&2
  exit 1
fi

if [[ -f "${LIB_DIR}/resolve_python.sh" ]]; then
  # shellcheck source=lib/resolve_python.sh
  source "${LIB_DIR}/resolve_python.sh"
  resolve_python_bin || exit 1
  PYTHON="${RESOLVED_PYTHON}"
else
  PYTHON="python3"
fi

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-18027}"

cd "${APP_ROOT}"
exec "${PYTHON}" "${SCRIPT_DIR}/serve_web.py" "${PORT}" "${HOST}"
