#!/usr/bin/env bash
# family_smart_center — 托管 Web 静态站（默认端口 18027）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WEB_DIR="${1:-${WEB_DIR:-${APP_ROOT}/build/web}}"
PORT="${PORT:-18027}"
BIND="${BIND:-0.0.0.0}"

if [[ ! -d "${WEB_DIR}" ]] || [[ ! -f "${WEB_DIR}/index.html" ]]; then
  echo "错误: 未找到 ${WEB_DIR}/index.html" >&2
  echo "  · 本机构建: ./scripts/build_web_mac.sh" >&2
  echo "  · Windows 打包: 解压 zip 后 python3 -m http.server 18027" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "错误: 未找到 python3" >&2
  exit 1
fi

echo "托管 Web App: http://${BIND}:${PORT}"
cd "${WEB_DIR}"
exec python3 -m http.server "${PORT}" --bind "${BIND}"
