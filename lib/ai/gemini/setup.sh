#!/usr/bin/env bash

_GEMINI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_GEMINI_DIR/../../logging.sh"
source "$_GEMINI_DIR/../../platform.sh"

# ───────────────────────────────────────────────────────
#  Gemini CLI 설치
# ───────────────────────────────────────────────────────
install_gemini() {
  if command -v gemini &>/dev/null; then
    success "Gemini CLI 이미 설치됨"
    return
  fi

  info "Gemini CLI 설치 중..."
  if is_macos; then
    brew install gemini-cli
  else
    npm install -g @google/gemini-cli
  fi
  success "Gemini CLI 설치 완료"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_gemini
fi
