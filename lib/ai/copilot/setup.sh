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

# ───────────────────────────────────────────────────────
#  Copilot 전역 지시사항 심링크 설정
# ───────────────────────────────────────────────────────
setup_copilot_instructions() {
  local src="$_COPILOT_DIR/copilot-instructions.md"
  local dst="$HOME/.copilot/copilot-instructions.md"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    success "Copilot 전역 지시사항 이미 연결됨"
    return
  fi

  mkdir -p "$HOME/.copilot"
  [[ -f "$dst" && ! -L "$dst" ]] && cp "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  ln -sf "$src" "$dst"
  success "Copilot 전역 지시사항 연결 완료"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_copilot
  setup_copilot_instructions
fi
