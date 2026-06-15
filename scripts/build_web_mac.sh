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
flutter build web --release

echo ""
echo "构建完成: ${APP_ROOT}/build/web"
echo "启动静态站: ./scripts/serve_web_mac.sh"
