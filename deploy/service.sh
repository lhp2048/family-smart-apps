#!/usr/bin/env bash
# Service maintenance (single entry): install | start | stop | restart | status | uninstall
# Usage: ./service.sh install [--port 18027]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="${ROOT}/scripts"

usage() {
  cat <<'EOF'
Usage: ./service.sh <action> [options]

Actions:
  install    Register autostart + start service
  start      Start service
  stop       Stop service
  restart    Restart service (--force)
  status     Show service status
  diagnose   Check bind address + LAN self-test
  uninstall  Remove autostart + stop

Examples:
  ./service.sh install
  ./service.sh install --port 18027
  ./service.sh restart --force
EOF
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 1
fi

ACTION="$1"
shift

case "$(uname -s)" in
  Darwin) PLATFORM_SUFFIX=mac ;;
  Linux)  PLATFORM_SUFFIX=linux ;;
  MINGW* | MSYS* | CYGWIN*)
    echo "On Windows use: service.bat ${ACTION}" >&2
    exit 1
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

case "${ACTION}" in
  install)
    target="${SCRIPTS}/install_service_${PLATFORM_SUFFIX}.sh"
    if [[ ! -f "${target}" ]]; then
      target="${ROOT}/${PLATFORM_SUFFIX}/install_service_${PLATFORM_SUFFIX}.sh"
    fi
    if [[ ! -f "${target}" ]]; then
      echo "错误: 未找到 install_service_${PLATFORM_SUFFIX}.sh" >&2
      echo "请确认 zip 已完整解压（含 scripts/ 目录），或重新 build 并上传安装包。" >&2
      exit 127
    fi
    exec bash "${target}" "$@"
    ;;
  start)
    target="${SCRIPTS}/start_service_${PLATFORM_SUFFIX}.sh"
    if [[ ! -f "${target}" ]]; then
      echo "错误: 未找到 ${target}" >&2
      exit 127
    fi
    exec bash "${target}" "$@"
    ;;
  stop)
    target="${SCRIPTS}/stop_service_${PLATFORM_SUFFIX}.sh"
    if [[ ! -f "${target}" ]]; then
      echo "错误: 未找到 ${target}" >&2
      exit 127
    fi
    exec bash "${target}" "$@"
    ;;
  restart)
    target="${SCRIPTS}/restart_service_${PLATFORM_SUFFIX}.sh"
    if [[ ! -f "${target}" ]]; then
      echo "错误: 未找到 ${target}" >&2
      exit 127
    fi
    exec bash "${target}" "$@"
    ;;
  status)
    target="${SCRIPTS}/install_service_${PLATFORM_SUFFIX}.sh"
    if [[ ! -f "${target}" ]]; then
      echo "错误: 未找到 ${target}" >&2
      exit 127
    fi
    exec bash "${target}" --status "$@"
    ;;
  diagnose)
    if [[ -f "${SCRIPTS}/lib/service_common.sh" ]]; then
      # shellcheck source=lib/service_common.sh
      source "${SCRIPTS}/lib/service_common.sh"
    fi
    if [[ -f "${SCRIPTS}/lib/resolve_python.sh" ]]; then
      # shellcheck source=lib/resolve_python.sh
      source "${SCRIPTS}/lib/resolve_python.sh"
      show_python_info
    fi
    if declare -F run_diagnose >/dev/null; then
      run_diagnose "${PORT:-18027}" "0.0.0.0"
      exit $?
    fi
    echo "service_common.sh not found" >&2
    exit 1
    ;;
  uninstall)
    target="${SCRIPTS}/install_service_${PLATFORM_SUFFIX}.sh"
    if [[ ! -f "${target}" ]]; then
      echo "错误: 未找到 ${target}" >&2
      exit 127
    fi
    exec bash "${target}" --uninstall "$@"
    ;;
  -h | --help | help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown action: ${ACTION}" >&2
    usage >&2
    exit 1
    ;;
esac
