#!/usr/bin/env bash
# Preview build/web locally (default :18027)
# Usage: ./scripts/serve.sh [port]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WEB_DIR="${APP_ROOT}/build/web"
PORT="${1:-${PORT:-18027}}"
HOST="${HOST:-127.0.0.1}"

if [[ ! -f "${WEB_DIR}/index.html" ]]; then
  echo "错误: 未找到 ${WEB_DIR}/index.html" >&2
  echo "  请先执行: ./scripts/build.sh" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "错误: 未找到 python3" >&2
  exit 1
fi

echo "Web App: http://${HOST}:${PORT}/"
cd "${WEB_DIR}"
if [[ -f "${WEB_DIR}/scripts/serve_web.py" ]]; then
  exec python3 "${WEB_DIR}/scripts/serve_web.py" "${PORT}" "${HOST}"
else
  exec python3 -m http.server "${PORT}" --bind "${HOST}"
fi
