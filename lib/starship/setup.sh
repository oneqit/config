#!/usr/bin/env bash

_STARSHIP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_STARSHIP_DIR/../logging.sh"

# ───────────────────────────────────────────────────────
#  Starship 설정
# ───────────────────────────────────────────────────────
setup_starship_config() {
  local config_dir="$HOME/.config"
  local src="$_STARSHIP_DIR/starship.toml"
  local dst="$config_dir/starship.toml"

  mkdir -p "$config_dir"

  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    success "Starship 설정 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$dst" ]]; then
    warn "starship.toml 이미 존재 → 백업 후 덮어쓰기"
    cp "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "Starship 설정 파일 생성 중..."
  cp "$src" "$dst"
  success "Starship 설정 완료 → \"$dst\""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_starship_config
fi
