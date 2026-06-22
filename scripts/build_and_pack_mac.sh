#!/usr/bin/env bash
# 构建 Web Release 并打包 zip（仅 family_smart_apps）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/build_web_mac.sh"
"${SCRIPT_DIR}/pack_web_mac.sh"
