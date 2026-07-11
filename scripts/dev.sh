#!/usr/bin/env bash
# family_smart_apps Web 本地开发（flutter run -d chrome）
# 用法: ./scripts/dev.sh [port]  默认 :18027
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${APP_ROOT}"

PORT="${1:-18027}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "错误: 未找到 flutter" >&2
  exit 1
fi

pids="$(lsof -ti "tcp:${PORT}" 2>/dev/null || true)"
if [[ -n "${pids}" ]]; then
  echo "[dev] 释放端口 ${PORT} ..."
  kill ${pids} 2>/dev/null || true
  sleep 1
fi

echo "App: http://127.0.0.1:${PORT}/"
exec flutter run -d chrome --web-port="${PORT}" --web-hostname=127.0.0.1
