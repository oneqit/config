#!/usr/bin/env bash

_STARSHIP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_STARSHIP_DIR/../deploy.sh"

# ───────────────────────────────────────────────────────
#  Starship 설정
# ───────────────────────────────────────────────────────
setup_starship_config() {
  deploy_config "Starship 설정" "$_STARSHIP_DIR/starship.toml" "$HOME/.config/starship.toml"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_starship_config
fi
