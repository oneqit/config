#!/usr/bin/env bash

_ZSH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_ZSH_DIR/../logging.sh"

# ───────────────────────────────────────────────────────
#  Oh My Zsh 설치
# ───────────────────────────────────────────────────────
install_oh_my_zsh() {
  local omz_dir="$HOME/.oh-my-zsh"

  if [[ -d "$omz_dir" ]]; then
    success "Oh My Zsh 이미 설치됨"
  else
    info "Oh My Zsh 설치 중..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "Oh My Zsh 설치 완료"
  fi

  local plugins=(
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-completions
  )

  for repo in "${plugins[@]}"; do
    local name="${repo##*/}"
    local dir="${ZSH_CUSTOM:-$omz_dir/custom}/plugins/$name"
    if [[ -d "$dir" ]]; then
      success "$name 이미 설치됨"
    else
      info "$name 설치 중..."
      git clone "https://github.com/$repo" "$dir"
      success "$name 설치 완료"
    fi
  done
}

# ───────────────────────────────────────────────────────
#  .zshrc 설정
# ───────────────────────────────────────────────────────
setup_zshrc() {
  local zshrc="$HOME/.zshrc"
  local extras=""
  local extras_marker="#  Extras"
  local tmp_file

  if [[ -f "$zshrc" ]]; then
    extras=$(sed -n "/${extras_marker}/,\$p" "$zshrc" | tail -n +3)
    # leading/trailing 빈 줄 제거
    while [[ "$extras" == $'\n'* ]]; do extras="${extras#$'\n'}"; done
    while [[ "$extras" == *$'\n' ]]; do extras="${extras%$'\n'}"; done
  fi

  local repo_dir
  repo_dir="$(cd "$_ZSH_DIR/../.." && pwd)"

  tmp_file="$(mktemp)"
  sed "s|__ONEQIT_CONFIG__|$repo_dir|g" "$_ZSH_DIR/.zshrc" > "$tmp_file"
  if [[ -n "$extras" ]]; then
    printf '%s\n' "$extras" >> "$tmp_file"
  fi

  if [[ -f "$zshrc" ]] && cmp -s "$tmp_file" "$zshrc"; then
    rm -f "$tmp_file"
    success ".zshrc 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$zshrc" ]]; then
    warn ".zshrc 이미 존재 → 백업"
    cp "$zshrc" "${zshrc}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info ".zshrc 생성 중..."
  mv "$tmp_file" "$zshrc"
  success ".zshrc 설정 완료 → \"$zshrc\""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_oh_my_zsh
  setup_zshrc
fi
