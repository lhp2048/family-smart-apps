#!/usr/bin/env bash
# 重启/后台启动家庭智能中心 Web 静态站（macOS）
#
# 用法:
#   ./scripts/restart_service_mac.sh           # 后台重启（优先 launchd，否则 nohup）
#   ./scripts/restart_service_mac.sh --force   # 强制杀端口后重启
#   ./scripts/restart_service_mac.sh --manual  # 不用 launchd，nohup 后台启动
#   ./scripts/restart_service_mac.sh --check   # 仅检查端口
#
set -euo pipefail

LABEL="com.family.smart.apps-web"
_set_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${_set_dir}/lib/paths.sh" ]]; then
  source "${_set_dir}/lib/paths.sh"
else
  source "${_set_dir}/../lib/paths.sh"
fi
apps_web_init_paths || exit 1
RUN_SCRIPT="${SCRIPT_DIR}/run_web.sh"
PLIST_DEST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
LOG_DIR="${HOME}/Library/Logs/family-smart-apps-web"
PID_FILE="${LOG_DIR}/web-app.pid"

MODE="auto"
PORT="18027"
DO_FORCE=0

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
}

launchctl_user_domain() {
  echo "gui/$(id -u)"
}

is_port_listening() {
  lsof -ti tcp:"${PORT}" >/dev/null 2>&1
}

health_check() {
  local url="http://127.0.0.1:${PORT}/"
  if curl -sf "${url}" >/dev/null 2>&1; then
    echo "Web App 正常: ${url}"
    return 0
  fi
  echo "访问失败: ${url}" >&2
  echo "查看日志: tail -f ${LOG_DIR}/stderr.log" >&2
  return 1
}

kill_port() {
  local pids
  pids="$(lsof -ti tcp:"${PORT}" 2>/dev/null || true)"
  if [[ -n "${pids}" ]]; then
    echo "停止占用端口 ${PORT} 的进程: ${pids}"
    kill ${pids} 2>/dev/null || true
    sleep 1
    pids="$(lsof -ti tcp:"${PORT}" 2>/dev/null || true)"
    if [[ -n "${pids}" ]]; then
      kill -9 ${pids} 2>/dev/null || true
    fi
  fi
  rm -f "${PID_FILE}"
}

restart_launchd() {
  local domain
  domain="$(launchctl_user_domain)"
  if [[ ! -f "${PLIST_DEST}" ]]; then
    return 1
  fi
  echo "通过 launchctl 重启 ${LABEL} ..."
  if ! launchctl print "${domain}/${LABEL}" &>/dev/null; then
    launchctl bootstrap "${domain}" "${PLIST_DEST}"
  else
    launchctl kickstart -k "${domain}/${LABEL}"
  fi
  echo "launchd 已触发，Web App 在后台运行。"
  echo "  地址: http://127.0.0.1:${PORT}"
  echo "  日志: tail -f ${LOG_DIR}/stdout.log"
  return 0
}

start_background() {
  mkdir -p "${LOG_DIR}"
  chmod +x "${RUN_SCRIPT}" 2>/dev/null || true
  nohup bash "${RUN_SCRIPT}" >> "${LOG_DIR}/stdout.log" 2>> "${LOG_DIR}/stderr.log" &
  local pid=$!
  echo "${pid}" > "${PID_FILE}"
  disown "${pid}" 2>/dev/null || true
  echo "已后台启动，PID=${pid}"
  echo "  地址: http://127.0.0.1:${PORT}"
  echo "  日志: tail -f ${LOG_DIR}/stdout.log"
}

restart_manual() {
  echo "后台重启（nohup）..."
  kill_port
  start_background
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --manual) MODE="manual"; shift ;;
    --check)  MODE="check"; shift ;;
    --force)  DO_FORCE=1; shift ;;
    --port)   PORT="${2:-18027}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "错误: 此脚本仅适用于 macOS" >&2
  exit 1
fi

if [[ ! -f "${APP_ROOT}/index.html" ]]; then
  echo "错误: 未找到 ${APP_ROOT}/index.html" >&2
  exit 1
fi

if [[ "${MODE}" == "check" ]]; then
  health_check
  exit $?
fi

if [[ "${DO_FORCE}" -eq 0 ]] && is_port_listening; then
  echo "Web App 已在运行（端口 ${PORT}）。"
  echo "  地址: http://127.0.0.1:${PORT}"
  echo "  强制重启: ./scripts/restart_service_mac.sh --force"
  exit 0
fi

case "${MODE}" in
  manual)
    restart_manual
    ;;
  auto)
    if [[ "${DO_FORCE}" -eq 1 ]]; then
      if restart_launchd; then
        :
      else
        restart_manual
      fi
    elif restart_launchd; then
      :
    else
      echo "未检测到 launchd，使用 nohup 后台启动"
      restart_manual
    fi
    ;;
esac

sleep 1
health_check || {
  echo "WARN: 端口 ${PORT} 暂未响应，launchd 可能仍在启动" >&2
  echo "  日志: tail -f ${LOG_DIR}/stderr.log" >&2
}
exit 0
