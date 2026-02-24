#!/usr/bin/env bash

_GHOSTTY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_GHOSTTY_DIR/../deploy.sh"

# ───────────────────────────────────────────────────────
#  Ghostty 설치
# ───────────────────────────────────────────────────────
install_ghostty() {
  if [[ -d "/Applications/Ghostty.app" ]] || brew list --cask ghostty &>/dev/null; then
    success "Ghostty 이미 설치됨"
  else
    info "Ghostty 설치 중..."
    brew install --cask ghostty
    success "Ghostty 설치 완료"
  fi
}

# ───────────────────────────────────────────────────────
#  Ghostty 설정
# ───────────────────────────────────────────────────────
setup_ghostty_config() {
  deploy_config "Ghostty 설정" "$_GHOSTTY_DIR/config" "$HOME/.config/ghostty/config"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_ghostty
  setup_ghostty_config
fi
