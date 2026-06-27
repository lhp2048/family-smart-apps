#!/usr/bin/env bash
# Build Web Release
# Usage: ./scripts/build.sh
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

"${SCRIPT_DIR}/stage_web_deploy.sh"

echo "构建完成: ${APP_ROOT}/build/web"
echo "打包 zip: ./scripts/pack.sh  ->  dist_out/family_smart_apps_web.zip"
echo "一键构建打包: ./scripts/build_and_pack.sh"
echo "本地预览: ./scripts/serve.sh"
