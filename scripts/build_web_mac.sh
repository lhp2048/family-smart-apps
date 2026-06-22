#!/usr/bin/env bash
# family_smart_center — 构建 Web Release 静态站
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${APP_ROOT}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "错误: 未找到 flutter，请先安装 Flutter SDK" >&2
  exit 1
fi

flutter pub get
dart run tool/generate_build_stamp.dart
flutter build web --release --base-href=/ --pwa-strategy=none

mkdir -p "${APP_ROOT}/build/web/scripts"
cp "${APP_ROOT}/deploy/mac/"*.sh "${APP_ROOT}/build/web/scripts/"
cp "${APP_ROOT}/deploy/mac/serve_web.py" "${APP_ROOT}/build/web/scripts/serve_web.py"
cp "${APP_ROOT}/deploy/web/flutter_service_worker_uninstall.js" "${APP_ROOT}/build/web/flutter_service_worker.js"
cp "${APP_ROOT}/deploy/mac/INSTALL.txt" "${APP_ROOT}/build/web/INSTALL.txt"
chmod +x "${APP_ROOT}/build/web/scripts/"*.sh 2>/dev/null || true

echo "构建完成: ${APP_ROOT}/build/web"
echo "打包 zip: ./scripts/pack_web_mac.sh  ->  dist_out/family_smart_apps_web.zip"
echo "一键构建打包: ./scripts/build_and_pack_mac.sh"
echo "本地预览: ./scripts/serve_web_mac.sh"
