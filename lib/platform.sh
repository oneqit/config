#!/usr/bin/env bash

_PLATFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_PLATFORM_DIR/logging.sh"

# ───────────────────────────────────────────────────────
#  플랫폼 판별
# ───────────────────────────────────────────────────────
is_termux() {
  [[ -n "${TERMUX_VERSION:-}" ]] && return 0
  [[ "${PREFIX:-}" == *com.termux/files/usr ]] && return 0
  command -v termux-setup-storage >/dev/null 2>&1 && return 0
  return 1
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

ensure_termux() {
  is_termux || error "이 스크립트는 Termux 환경에서 실행해야 합니다"
}

ensure_macos() {
  is_macos || error "이 스크립트는 macOS 환경에서 실행해야 합니다"
}
