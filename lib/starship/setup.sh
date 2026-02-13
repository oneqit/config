#!/usr/bin/env bash

_STARSHIP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_STARSHIP_DIR/../logging.sh"

# ───────────────────────────────────────────────────────
#  Starship 설정
# ───────────────────────────────────────────────────────
setup_starship_config() {
  local config_dir="$HOME/.config"
  local config_file="$config_dir/starship.toml"

  mkdir -p "$config_dir"

  if [[ -f "$config_file" ]] && cmp -s "$_STARSHIP_DIR/starship.toml" "$config_file"; then
    success "Starship 설정 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$config_file" ]]; then
    warn "starship.toml 이미 존재 → 백업 후 덮어쓰기"
    cp "$config_file" "${config_file}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "Starship 설정 파일 생성 중..."
  cp "$_STARSHIP_DIR/starship.toml" "$config_file"
  success "Starship 설정 완료 → \"$config_file\""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_starship_config
fi
