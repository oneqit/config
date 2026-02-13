#!/usr/bin/env bash

_KARABINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_KARABINER_DIR/../deploy.sh"

# ───────────────────────────────────────────────────────
#  Karabiner-Elements 설치
# ───────────────────────────────────────────────────────
install_karabiner() {
  if [[ -d "/Applications/Karabiner-Elements.app" ]] || brew list --cask karabiner-elements &>/dev/null; then
    success "Karabiner-Elements 이미 설치됨"
  else
    info "Karabiner-Elements 설치 중..."
    brew install --cask karabiner-elements
    success "Karabiner-Elements 설치 완료"
  fi
}

# ───────────────────────────────────────────────────────
#  Karabiner 설정
# ───────────────────────────────────────────────────────
setup_karabiner_config() {
  deploy_config "Karabiner 설정" "$_KARABINER_DIR/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_karabiner
  setup_karabiner_config
fi
