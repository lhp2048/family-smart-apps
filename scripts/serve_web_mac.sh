#!/usr/bin/env bash
# Deprecated: use family_smart_center_web/scripts/serve.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_ROOT="$(cd "${SCRIPT_DIR}/../../family_smart_center_web" && pwd)"
exec "${WEB_ROOT}/scripts/serve.sh" "$@"
