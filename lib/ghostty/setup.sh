#!/usr/bin/env bash

_GHOSTTY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_GHOSTTY_DIR/../logging.sh"

# ───────────────────────────────────────────────────────
#  Ghostty 설정
# ───────────────────────────────────────────────────────
setup_ghostty_config() {
  local config_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  local src="$_GHOSTTY_DIR/config"
  local dst="$config_dir/config"

  mkdir -p "$config_dir"

  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    success "Ghostty 설정 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$dst" ]]; then
    warn "Ghostty 설정 파일 이미 존재 → 백업 후 덮어쓰기"
    cp "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "Ghostty 설정 파일 생성 중..."
  cp "$src" "$dst"
  success "Ghostty 설정 완료 → \"$dst\""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_ghostty_config
fi
