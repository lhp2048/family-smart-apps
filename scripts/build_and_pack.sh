#!/usr/bin/env bash
# 构建 Web Release 并打包 zip
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/build.sh"
"${SCRIPT_DIR}/pack.sh"
