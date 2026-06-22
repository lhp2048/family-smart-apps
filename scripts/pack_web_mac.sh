#!/usr/bin/env bash
# 将 build/web 打包为 zip（Mac 部署用）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WEB_DIR="${APP_ROOT}/build/web"
OUT_DIR="${APP_ROOT}/dist_out"
ZIP_FILE="${OUT_DIR}/family_smart_apps_web.zip"

if [[ ! -f "${WEB_DIR}/index.html" ]]; then
  echo "错误: 未找到 ${WEB_DIR}/index.html" >&2
  echo "  请先执行: ./scripts/build_web_mac.sh" >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"
rm -f "${ZIP_FILE}"

(
  cd "${WEB_DIR}"
  zip -r "${ZIP_FILE}" . >/dev/null
)

echo ""
echo "Packed: ${ZIP_FILE}"
