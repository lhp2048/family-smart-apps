#!/usr/bin/env bash
# 家庭看板 Web 静态站 — launchd / 前台启动包装
set -euo pipefail

_set_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${_set_dir}/lib/paths.sh" ]]; then
  source "${_set_dir}/lib/paths.sh"
else
  source "${_set_dir}/../lib/paths.sh"
fi
apps_web_init_paths || exit 1
LIB_DIR="${LIB_DIR:-${SCRIPT_DIR}/lib}"

if [[ ! -f "${APP_ROOT}/index.html" ]]; then
  echo "错误: 未找到 ${APP_ROOT}/index.html" >&2
  exit 1
fi

if [[ -f "${LIB_DIR}/resolve_python.sh" ]]; then
  # shellcheck source=lib/resolve_python.sh
  source "${LIB_DIR}/resolve_python.sh"
  resolve_python_bin || exit 1
  PYTHON="${RESOLVED_PYTHON}"
else
  if ! command -v python3 >/dev/null 2>&1; then
    echo "错误: 未找到 python3" >&2
    exit 1
  fi
  PYTHON="$(command -v python3)"
fi

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-18027}"

cd "${APP_ROOT}"
exec "${PYTHON}" "${SCRIPT_DIR}/serve_web.py" "${PORT}" "${HOST}"
