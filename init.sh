#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/platform.sh"

main() {
  local target

  if is_termux; then
    target="$SCRIPT_DIR/termux/init.sh"
  elif is_macos; then
    target="$SCRIPT_DIR/macos/init.sh"
  else
    error "지원하지 않는 OS입니다: $(uname -s) (지원 환경: macOS, Termux)"
  fi

  [[ ! -f "$target" ]] && error "스크립트를 찾을 수 없습니다: $target"
  [[ ! -x "$target" ]] && chmod +x "$target"

  "$target" "$@"
}

main "$@"
