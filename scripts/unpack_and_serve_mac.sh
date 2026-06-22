#!/usr/bin/env bash
# family_smart_apps — 解压 Windows 打包的 Web 静态站并托管（默认 :18027）
# 用法:
#   ./scripts/unpack_and_serve_mac.sh ~/Downloads/family_smart_center_web.zip
#   ./scripts/unpack_and_serve_mac.sh ~/Downloads/family_smart_center_web.zip ~/Sites/fsc_web
set -euo pipefail

ZIP="${1:-}"
DEST="${2:-${HOME}/family_smart_center_web}"
PORT="${PORT:-18027}"
BIND="${BIND:-0.0.0.0}"

if [[ -z "${ZIP}" ]] || [[ ! -f "${ZIP}" ]]; then
  echo "用法: $0 <family_smart_center_web.zip> [解压目录]" >&2
  echo "示例: $0 ~/Downloads/family_smart_center_web.zip" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "错误: 未找到 python3" >&2
  exit 1
fi

mkdir -p "${DEST}"
echo "解压到: ${DEST}"
unzip -o "${ZIP}" -d "${DEST}" >/dev/null

if [[ ! -f "${DEST}/index.html" ]]; then
  echo "错误: 解压后未找到 ${DEST}/index.html，请确认 zip 由 scripts/pack_web_for_mac_win.bat 生成" >&2
  exit 1
fi

echo ""
echo "Web App: http://${BIND}:${PORT}"
echo "局域网: http://<本机IP>:${PORT}"
echo ""
cd "${DEST}"
exec python3 -m http.server "${PORT}" --bind "${BIND}"
