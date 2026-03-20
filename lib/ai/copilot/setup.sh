#!/usr/bin/env bash

_COPILOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_COPILOT_DIR/../../logging.sh"
source "$_COPILOT_DIR/../../platform.sh"

# ───────────────────────────────────────────────────────
#  GitHub Copilot CLI 설치
# ───────────────────────────────────────────────────────
install_copilot() {
  if command -v copilot &>/dev/null; then
    success "GitHub Copilot CLI 이미 설치됨"
    return
  fi

  info "GitHub Copilot CLI 설치 중..."
  if is_macos; then
    brew install copilot-cli
  else
    npm install -g @github/copilot
  fi
  success "GitHub Copilot CLI 설치 완료"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_copilot
fi
