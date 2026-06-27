#!/usr/bin/env bash
# Resolve Python >= 3.10 for static web server (stdlib only).
# Usage:
#   source scripts/lib/resolve_python.sh
#   resolve_python_bin

MIN_PYTHON_MAJOR=3
MIN_PYTHON_MINOR=10

PYTHON_CANDIDATES=(
  python3.13
  python3.12
  python3.11
  python3.10
  /opt/homebrew/bin/python3.13
  /opt/homebrew/bin/python3.12
  /opt/homebrew/bin/python3.11
  /opt/homebrew/bin/python3.10
  /usr/local/bin/python3.13
  /usr/local/bin/python3.12
  /usr/local/bin/python3.11
  /usr/local/bin/python3.10
)

_python_meets_minimum() {
  local bin="$1"
  "${bin}" -c "import sys; raise SystemExit(0 if sys.version_info >= (${MIN_PYTHON_MAJOR}, ${MIN_PYTHON_MINOR}) else 1)" 2>/dev/null
}

_python_try_select() {
  local bin="$1"
  if [[ -x "${bin}" ]]; then
    :
  elif command -v "${bin}" >/dev/null 2>&1; then
    bin="$(command -v "${bin}")"
  else
    return 1
  fi
  if _python_meets_minimum "${bin}"; then
    RESOLVED_PYTHON="${bin}"
    RESOLVED_PYTHON_VERSION="$("${bin}" --version 2>&1 | head -n 1)"
    return 0
  fi
  return 1
}

_list_python_candidates() {
  local c seen=""
  for c in python3.13 python3.12 python3.11 python3.10 python3; do
    if [[ -x "${c}" ]] || command -v "${c}" >/dev/null 2>&1; then
      local bin="${c}"
      [[ -x "${bin}" ]] || bin="$(command -v "${bin}")"
      case " ${seen} " in
        *" ${bin} "*) continue ;;
      esac
      seen="${seen} ${bin}"
      echo "  ${bin}: $("${bin}" --version 2>&1 | head -n 1)"
    fi
  done
}

resolve_python_bin() {
  local requested="${1:-}"
  RESOLVED_PYTHON=""
  RESOLVED_PYTHON_VERSION=""

  if [[ -n "${requested}" ]]; then
    _python_try_select "${requested}" && return 0
    echo "ERROR: ${requested} not found or Python < ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR}" >&2
    return 1
  fi

  if [[ -n "${PYTHON_BIN:-}" ]]; then
    _python_try_select "${PYTHON_BIN}" && return 0
    echo "ERROR: PYTHON_BIN=${PYTHON_BIN} is not usable (need >= 3.10)" >&2
    return 1
  fi

  local c
  for c in "${PYTHON_CANDIDATES[@]}"; do
    _python_try_select "${c}" && return 0
  done

  if command -v python3 >/dev/null 2>&1; then
    _python_try_select "$(command -v python3)" && return 0
  fi

  echo "ERROR: Python >= ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR} required." >&2
  echo "Install python3.12 or run: PYTHON_BIN=python3.12 ./service.sh install" >&2
  echo "Detected:" >&2
  _list_python_candidates >&2
  return 1
}

show_python_info() {
  echo "Python candidates:"
  _list_python_candidates
  if [[ -n "${RESOLVED_PYTHON:-}" ]]; then
    echo "Selected: ${RESOLVED_PYTHON}"
    echo "  ${RESOLVED_PYTHON_VERSION}"
  elif resolve_python_bin 2>/dev/null; then
    echo "Selected: ${RESOLVED_PYTHON}"
    echo "  ${RESOLVED_PYTHON_VERSION}"
  else
    echo "Selected: (none)"
  fi
}
