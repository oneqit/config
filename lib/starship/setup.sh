#!/usr/bin/env bash

_STARSHIP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_STARSHIP_DIR/../deploy.sh"
source "$_STARSHIP_DIR/../platform.sh"

# ───────────────────────────────────────────────────────
#  Starship 설치 (macOS, Linux — 공식 스크립트로 최신 버전)
# ───────────────────────────────────────────────────────
install_starship() {
  if command -v starship &>/dev/null; then
    success "Starship 이미 설치됨"
    return
  fi

  info "Starship 설치 중..."
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
  success "Starship 설치 완료"
}

# ───────────────────────────────────────────────────────
#  Starship 설정
# ───────────────────────────────────────────────────────
setup_starship_config() {
  deploy_config "Starship 설정" "$_STARSHIP_DIR/starship.toml" "$HOME/.config/starship.toml"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  is_termux || install_starship
  setup_starship_config
  echo ""
  warn ".zshrc에 아래 설정이 필요합니다"
  info "  eval \"\$(starship init zsh)\""
  info "  → .zshrc에 해당 설정이 있는지 확인해주세요"
fi
