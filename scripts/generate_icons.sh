#!/usr/bin/env bash
# Regenerate launcher icons and splash screens from assets/app_icon/app_icon_source.png
# Usage: ./scripts/generate_icons.sh
# Run after replacing app_icon_source.png (1024x1024 PNG).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$APP_ROOT"

FLUTTER="${FLUTTER_BIN:-flutter}"

echo "Flutter: $FLUTTER"
echo "Workdir: $PWD"
echo

"$FLUTTER" pub get
python "$APP_ROOT/tool/process_app_icon.py"
dart run flutter_launcher_icons
dart run flutter_native_splash:create

echo
echo "Done: launcher icons + splash screens regenerated from assets/app_icon/app_icon_source.png"
