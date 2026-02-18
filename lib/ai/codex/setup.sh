#!/usr/bin/env bash

_CODEX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_CODEX_DIR/../../logging.sh"
source "$_CODEX_DIR/../../platform.sh"

# ───────────────────────────────────────────────────────
#  Codex CLI 설치
# ───────────────────────────────────────────────────────
install_codex() {
  if command -v codex &>/dev/null; then
    success "Codex CLI 이미 설치됨"
    return
  fi

  info "Codex CLI 설치 중..."
  if is_macos; then
    brew install codex
  else
    npm install -g @openai/codex
  fi
  success "Codex CLI 설치 완료"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_codex
fi
