#!/usr/bin/env bash

_TMUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_TMUX_DIR/../deploy.sh"

# ───────────────────────────────────────────────────────
#  tmux 설정
# ───────────────────────────────────────────────────────
setup_tmux() {
  deploy_config "tmux 설정" "$_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_tmux
fi
