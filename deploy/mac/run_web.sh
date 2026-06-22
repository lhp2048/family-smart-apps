#!/usr/bin/env bash
# 家庭智能中心 Web 静态站 — launchd / 前台启动包装
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ ! -f "${APP_ROOT}/index.html" ]]; then
  echo "错误: 未找到 ${APP_ROOT}/index.html" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "错误: 未找到 python3" >&2
  exit 1
fi

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-18027}"

cd "${APP_ROOT}"
exec python3 "${SCRIPT_DIR}/serve_web.py" "${PORT}" "${HOST}"
