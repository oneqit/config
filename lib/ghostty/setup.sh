#!/usr/bin/env bash

_GHOSTTY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_GHOSTTY_DIR/../deploy.sh"

# ───────────────────────────────────────────────────────
#  Ghostty 설정
# ───────────────────────────────────────────────────────
setup_ghostty_config() {
  deploy_config "Ghostty 설정" "$_GHOSTTY_DIR/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_ghostty_config
fi
