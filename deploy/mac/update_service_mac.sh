#!/usr/bin/env bash
# macOS：从 zip 覆盖解压 family_smart_apps Web 静态站，并升级/重启 launchd 服务
#
# 用法:
#   ./scripts/update_service_mac.sh <zip路径> <解压目录>
#   ./scripts/update_service_mac.sh ~/Downloads/family_smart_apps.zip ~/family_smart_apps_web
#
# 说明:
#   - 覆盖解压到指定目录（保留目录内未出现在 zip 中的旧文件）
#   - 若已安装 launchd 服务则先停止，解压后重新 install + 重启
#   - 默认端口 18027（与 install_service_mac.sh 一致）
#
set -euo pipefail

LABEL="com.familybot.web-app"
PLIST_DEST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
LOG_DIR="${HOME}/Library/Logs/familybot-web-app"

ZIP="${1:-}"
DEST="${2:-}"
PORT="18027"

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

launchctl_user_domain() {
  echo "gui/$(id -u)"
}

stop_service() {
  local domain
  domain="$(launchctl_user_domain)"
  if [[ -f "${PLIST_DEST}" ]]; then
    echo "==> 停止 launchd 服务 ${LABEL} ..."
    launchctl bootout "${domain}" "${PLIST_DEST}" 2>/dev/null || true
  fi
  local pids
  pids="$(lsof -ti tcp:"${PORT}" 2>/dev/null || true)"
  if [[ -n "${pids}" ]]; then
    echo "==> 停止占用端口 ${PORT} 的进程: ${pids}"
    kill ${pids} 2>/dev/null || true
    sleep 1
    pids="$(lsof -ti tcp:"${PORT}" 2>/dev/null || true)"
    if [[ -n "${pids}" ]]; then
      kill -9 ${pids} 2>/dev/null || true
    fi
  fi
}

normalize_app_root() {
  if [[ -f "${DEST}/index.html" ]]; then
    return 0
  fi
  local sub
  sub="$(find "${DEST}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1 || true)"
  if [[ -n "${sub}" && -f "${sub}/index.html" ]]; then
    echo "==> 检测到 zip 含顶层子目录，合并到 ${DEST} ..."
    shopt -s dotglob nullglob
    mv "${sub}"/* "${DEST}/" 2>/dev/null || true
    shopt -u dotglob nullglob
    rmdir "${sub}" 2>/dev/null || true
  fi
  if [[ ! -f "${DEST}/index.html" ]]; then
    echo "错误: 解压后未找到 ${DEST}/index.html，请确认 zip 为 Web 构建产物" >&2
    exit 1
  fi
}

fix_script_line_endings() {
  if [[ ! -d "${DEST}/scripts" ]]; then
    return 0
  fi
  local f
  for f in "${DEST}/scripts/"*.sh; do
    [[ -f "${f}" ]] || continue
    if grep -q $'\r' "${f}" 2>/dev/null; then
      echo "==> 修正脚本换行: $(basename "${f}")"
      sed -i '' $'s/\r$//' "${f}"
    fi
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port) PORT="${2:-18027}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [[ -z "${ZIP}" ]]; then
        ZIP="$1"
      elif [[ -z "${DEST}" ]]; then
        DEST="$1"
      else
        echo "未知参数: $1" >&2
        usage
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "错误: 此脚本仅适用于 macOS" >&2
  exit 1
fi

if [[ -z "${ZIP}" || -z "${DEST}" ]]; then
  echo "用法: $0 <zip路径> <解压目录> [--port 18027]" >&2
  echo "示例: $0 ~/Downloads/family_smart_apps.zip ~/family_smart_apps_web" >&2
  exit 1
fi

if [[ ! -f "${ZIP}" ]]; then
  echo "错误: zip 不存在: ${ZIP}" >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "错误: 未找到 unzip" >&2
  exit 1
fi

echo "==> zip:  ${ZIP}"
echo "==> 目录: ${DEST}"
echo "==> 端口: ${PORT}"

stop_service

mkdir -p "${DEST}"
echo "==> 覆盖解压 ..."
unzip -o "${ZIP}" -d "${DEST}" >/dev/null

normalize_app_root
fix_script_line_endings

if [[ -d "${DEST}/scripts" ]]; then
  chmod +x "${DEST}/scripts/"*.sh 2>/dev/null || true
fi

INSTALL_SCRIPT="${DEST}/scripts/install_service_mac.sh"
RESTART_SCRIPT="${DEST}/scripts/restart_service_mac.sh"

if [[ ! -x "${INSTALL_SCRIPT}" ]]; then
  echo "错误: 未找到 ${INSTALL_SCRIPT}" >&2
  exit 1
fi

echo "==> 升级 launchd 服务配置并启动 ..."
if [[ -n "${PORT}" && "${PORT}" != "18027" ]]; then
  bash "${INSTALL_SCRIPT}" --port "${PORT}"
else
  bash "${INSTALL_SCRIPT}"
fi

sleep 1
if [[ -x "${RESTART_SCRIPT}" ]]; then
  bash "${RESTART_SCRIPT}" --force --port "${PORT}" || true
fi

if curl -sf "http://127.0.0.1:${PORT}/" >/dev/null 2>&1; then
  echo ""
  echo "升级完成。"
  echo "  访问: http://127.0.0.1:${PORT}"
  echo "  状态: ${DEST}/scripts/install_service_mac.sh --status"
  echo "  日志: tail -f ${LOG_DIR}/stdout.log"
else
  echo ""
  echo "升级已解压并完成服务加载，但端口 ${PORT} 暂未响应。" >&2
  echo "  请查看: tail -f ${LOG_DIR}/stderr.log" >&2
  exit 1
fi
