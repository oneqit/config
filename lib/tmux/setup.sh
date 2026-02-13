#!/usr/bin/env bash

_TMUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_TMUX_DIR/../logging.sh"

# ───────────────────────────────────────────────────────
#  tmux 설정
# ───────────────────────────────────────────────────────
setup_tmux() {
  local tmux_conf_src="$_TMUX_DIR/.tmux.conf"
  local tmux_conf_dst="$HOME/.tmux.conf"

  if [[ -f "$tmux_conf_src" ]]; then
    ln -sf "$tmux_conf_src" "$tmux_conf_dst"
    success "tmux 설정 링크 적용: $tmux_conf_dst -> $tmux_conf_src"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_tmux
fi
