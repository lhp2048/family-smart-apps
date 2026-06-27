#!/usr/bin/env bash
# 将 build/web 打包为 zip，bump 版本，校验 manifest，写入 package-index
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WEB_ROOT="$(cd "${APP_ROOT}/../family_smart_center_web" && pwd)"
WEB_DIR="${APP_ROOT}/build/web"
OUT_DIR="${APP_ROOT}/dist_out"

PYTHON="python3"
if [[ -x "${WEB_ROOT}/.venv/bin/python" ]]; then
  PYTHON="${WEB_ROOT}/.venv/bin/python"
fi

if [[ ! -f "${WEB_DIR}/index.html" ]]; then
  echo "错误: 未找到 ${WEB_DIR}/index.html" >&2
  echo "  请先执行: ./scripts/build.sh" >&2
  exit 1
fi

if [[ ! -f "${WEB_DIR}/scripts/install_service_mac.sh" ]]; then
  echo "build/web 缺少 deploy 脚本，正在执行 stage_web_deploy.sh ..."
  "${SCRIPT_DIR}/stage_web_deploy.sh"
fi

ZIP_NAME="$("${PYTHON}" -c "import json; print(json.load(open('${APP_ROOT}/family-product.json', encoding='utf-8')).get('zipNameHint', 'family_smart_apps_web.zip'))")"
ZIP_FILE="${OUT_DIR}/${ZIP_NAME}"

"${PYTHON}" "${WEB_ROOT}/scripts/bump_manifest_version.py" \
  --manifest "${APP_ROOT}/family-product.json" \
  --dist "${WEB_DIR}"

"${PYTHON}" "${WEB_ROOT}/scripts/validate_manifest.py" "${APP_ROOT}/family-product.json" --dist "${WEB_DIR}"

mkdir -p "${OUT_DIR}"
rm -f "${ZIP_FILE}"

"${PYTHON}" "${WEB_ROOT}/scripts/make_zip.py" "${WEB_DIR}" "${ZIP_FILE}"

"${PYTHON}" "${WEB_ROOT}/scripts/write_package_info.py" \
  --manifest "${APP_ROOT}/family-product.json" \
  --zip "${ZIP_FILE}" \
  --dist "${WEB_DIR}" \
  --out-dir "${OUT_DIR}"

echo ""
echo "Packed: ${ZIP_FILE}"
