#!/usr/bin/env bash

_KARABINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_KARABINER_DIR/../logging.sh"

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
#  Karabiner 설정 (complex_modifications만 머지)
# ───────────────────────────────────────────────────────
setup_karabiner_config() {
  local src="$_KARABINER_DIR/karabiner.json"
  local dst="$HOME/.config/karabiner/karabiner.json"

  mkdir -p "$(dirname "$dst")"

  if [[ ! -f "$dst" ]]; then
    info "Karabiner 설정 적용 중..."
    cp "$src" "$dst"
    success "Karabiner 설정 적용 완료"
    return
  fi

  local result
  result=$(ruby -rjson -e '
    src = JSON.parse(File.read(ARGV[0]))
    dst = JSON.parse(File.read(ARGV[1]))

    profile = dst.dig("profiles", 0) || {}
    rules = profile.dig("complex_modifications", "rules") || []

    if rules.any?
      puts "SKIP"
    else
      src_rules = src.dig("profiles", 0, "complex_modifications", "rules") || []
      profile["complex_modifications"] ||= {}
      profile["complex_modifications"]["rules"] = src_rules
      File.write(ARGV[1], JSON.pretty_generate(dst) + "\n")
      puts "MERGED"
    end
  ' "$src" "$dst")

  case "$result" in
    SKIP)   success "Karabiner complex_modifications 이미 설정됨 → 스킵" ;;
    MERGED) success "Karabiner complex_modifications 머지 완료" ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_karabiner
  setup_karabiner_config
fi
