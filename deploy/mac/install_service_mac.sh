#!/usr/bin/env bash
# macOS：安装家庭智能中心 Web 静态站为 launchd 服务（登录后自动启动）
#
# 用法:
#   ./scripts/install_service_mac.sh              # 安装并启动（用户级 LaunchAgent）
#   ./scripts/install_service_mac.sh --uninstall  # 卸载服务
#   ./scripts/install_service_mac.sh --status      # 查看状态
#
# 说明:
#   - Plist: ~/Library/LaunchAgents/com.familybot.web-app.plist
#   - 日志: ~/Library/Logs/familybot-web-app/
#
set -euo pipefail

LABEL="com.familybot.web-app"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUN_SCRIPT="${SCRIPT_DIR}/run_web.sh"
PLIST_DEST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
LOG_DIR="${HOME}/Library/Logs/familybot-web-app"

DO_UNINSTALL=0
DO_STATUS=0
PORT="18027"
BIND="0.0.0.0"

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

launchctl_user_domain() {
  echo "gui/$(id -u)"
}

launchctl_load() {
  local domain
  domain="$(launchctl_user_domain)"
  if launchctl print "${domain}/${LABEL}" &>/dev/null; then
    launchctl bootout "${domain}" "${PLIST_DEST}" 2>/dev/null || true
  fi
  launchctl bootstrap "${domain}" "${PLIST_DEST}"
}

launchctl_unload() {
  local domain
  domain="$(launchctl_user_domain)"
  launchctl bootout "${domain}" "${PLIST_DEST}" 2>/dev/null || true
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall) DO_UNINSTALL=1; shift ;;
    --status)    DO_STATUS=1; shift ;;
    --port)      PORT="${2:-18027}"; shift 2 ;;
    --bind)      BIND="${2:-0.0.0.0}"; shift 2 ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "错误: 此脚本仅适用于 macOS" >&2
  exit 1
fi

if [[ "${DO_STATUS}" -eq 1 ]]; then
  domain="$(launchctl_user_domain)"
  echo "应用目录: ${APP_ROOT}"
  echo "Plist: ${PLIST_DEST}"
  if [[ -f "${PLIST_DEST}" ]]; then
    echo "已安装: 是"
  else
    echo "已安装: 否"
  fi
  if launchctl print "${domain}/${LABEL}" &>/dev/null; then
    echo "运行状态:"
    launchctl print "${domain}/${LABEL}" | sed -n '1,20p'
  else
    echo "运行状态: 未加载"
  fi
  echo "访问地址: http://127.0.0.1:${PORT}"
  echo "日志目录: ${LOG_DIR}"
  exit 0
fi

if [[ "${DO_UNINSTALL}" -eq 1 ]]; then
  echo "卸载 ${LABEL} ..."
  launchctl_unload
  rm -f "${PLIST_DEST}"
  echo "已移除 ${PLIST_DEST}"
  echo "（未删除 ${APP_ROOT}；日志保留在 ${LOG_DIR}）"
  exit 0
fi

if [[ ! -f "${APP_ROOT}/index.html" ]]; then
  echo "错误: 未找到 ${APP_ROOT}/index.html，请在解压目录内执行" >&2
  exit 1
fi

chmod +x "${RUN_SCRIPT}" "${SCRIPT_DIR}/start_service_mac.sh" "${SCRIPT_DIR}/restart_service_mac.sh" "${SCRIPT_DIR}/update_service_mac.sh" 2>/dev/null || true

echo "==> 应用目录: ${APP_ROOT}"
mkdir -p "${LOG_DIR}"
mkdir -p "${HOME}/Library/LaunchAgents"

cat > "${PLIST_DEST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${RUN_SCRIPT}</string>
    </array>
    <key>WorkingDirectory</key>
    <string>${APP_ROOT}</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${LOG_DIR}/stdout.log</string>
    <key>StandardErrorPath</key>
    <string>${LOG_DIR}/stderr.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
        <key>PORT</key>
        <string>${PORT}</string>
        <key>HOST</key>
        <string>${BIND}</string>
    </dict>
</dict>
</plist>
EOF

echo "==> 已写入 ${PLIST_DEST}"
launchctl_load
echo "==> 服务已加载并启动（登录后自动运行）"

sleep 1
if curl -sf "http://127.0.0.1:${PORT}/" >/dev/null 2>&1; then
  echo "==> 访问正常: http://127.0.0.1:${PORT}"
else
  echo "警告: 端口 ${PORT} 暂未响应，请查看日志:" >&2
  echo "  tail -f ${LOG_DIR}/stderr.log" >&2
fi

echo ""
echo "安装完成。"
echo "  运行:  ./scripts/start_service_mac.sh"
echo "  重启:  ./scripts/restart_service_mac.sh"
echo "  状态:  ./scripts/install_service_mac.sh --status"
echo "  卸载:  ./scripts/install_service_mac.sh --uninstall"
echo "  日志:  tail -f ${LOG_DIR}/stdout.log"
