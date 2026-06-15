#!/usr/bin/env bash
# 后台启动家庭智能中心 Web 静态站（macOS，立即返回）
#
# 用法:
#   ./scripts/start_service_mac.sh           # 未运行则启动；已运行则提示
#   ./scripts/start_service_mac.sh --force   # 先停端口再启动
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    -h|--help)
      sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done

RESTART="${SCRIPT_DIR}/restart_service_mac.sh"
if [[ "${FORCE}" -eq 1 ]]; then
  exec bash "${RESTART}" --force
else
  exec bash "${RESTART}"
fi
