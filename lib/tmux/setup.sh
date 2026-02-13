#!/usr/bin/env bash

_TMUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_TMUX_DIR/../logging.sh"

# ───────────────────────────────────────────────────────
#  tmux 설정
# ───────────────────────────────────────────────────────
setup_tmux() {
  local src="$_TMUX_DIR/.tmux.conf"
  local dst="$HOME/.tmux.conf"

  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    success "tmux 설정 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$dst" ]]; then
    warn ".tmux.conf 이미 존재 → 백업 후 덮어쓰기"
    cp "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "tmux 설정 파일 생성 중..."
  cp "$src" "$dst"
  success "tmux 설정 완료 → \"$dst\""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_tmux
fi
