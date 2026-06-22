#!/usr/bin/env bash
# 本地启动 family_smart_apps build/web（默认 :18027）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WEB_DIR="${APP_ROOT}/build/web"
PORT="${PORT:-18027}"
HOST="${HOST:-127.0.0.1}"

if [[ ! -f "${WEB_DIR}/index.html" ]]; then
  echo "错误: 未找到 ${WEB_DIR}/index.html" >&2
  echo "  请先执行: ./scripts/build_web_mac.sh" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "错误: 未找到 python3" >&2
  exit 1
fi

echo "Web App: http://${HOST}:${PORT}/"
cd "${WEB_DIR}"
exec python3 -m http.server "${PORT}" --bind "${HOST}"
