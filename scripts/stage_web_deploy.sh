#!/usr/bin/env bash
# Stage deploy scripts into build/web after flutter build
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WEB_DIR="${APP_ROOT}/build/web"
DEPLOY="${APP_ROOT}/deploy"
PORTAL_SCRIPTS="${APP_ROOT}/../family_smart_center_web/scripts"

if [[ ! -f "${WEB_DIR}/index.html" ]]; then
  echo "错误: 未找到 ${WEB_DIR}/index.html" >&2
  exit 1
fi

mkdir -p "${WEB_DIR}/scripts/lib"

cp "${DEPLOY}/INSTALL.txt" "${WEB_DIR}/INSTALL.txt"
for name in service install; do
  [[ -f "${DEPLOY}/${name}.bat" ]] && cp "${DEPLOY}/${name}.bat" "${WEB_DIR}/${name}.bat"
  [[ -f "${DEPLOY}/${name}.sh" ]] && cp "${DEPLOY}/${name}.sh" "${WEB_DIR}/${name}.sh"
done

cp "${DEPLOY}/windows/"*.bat "${WEB_DIR}/scripts/"
cp "${DEPLOY}/linux/"*.sh "${WEB_DIR}/scripts/"
cp "${DEPLOY}/mac/"*.sh "${WEB_DIR}/scripts/"
cp "${DEPLOY}/lib/"*.sh "${WEB_DIR}/scripts/lib/"
cp "${DEPLOY}/mac/serve_web.py" "${WEB_DIR}/scripts/serve_web.py"
cp "${DEPLOY}/web/flutter_service_worker_uninstall.js" "${WEB_DIR}/flutter_service_worker.js"
cp "${APP_ROOT}/family-product.json" "${WEB_DIR}/family-product.json"

chmod +x "${WEB_DIR}/"*.sh "${WEB_DIR}/scripts/"*.sh 2>/dev/null || true

PYTHON="python3"
if [[ -x "${APP_ROOT}/../family_smart_center_web/.venv/bin/python" ]]; then
  PYTHON="${APP_ROOT}/../family_smart_center_web/.venv/bin/python"
fi

if [[ -f "${PORTAL_SCRIPTS}/normalize_shell.py" ]]; then
  "${PYTHON}" "${PORTAL_SCRIPTS}/normalize_shell.py" "${WEB_DIR}/scripts" "${WEB_DIR}"
fi

echo "Staged deploy into: ${WEB_DIR}"
