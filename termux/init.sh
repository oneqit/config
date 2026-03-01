#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$REPO_DIR/lib/platform.sh"
source "$REPO_DIR/lib/zsh/setup.sh"
source "$REPO_DIR/lib/starship/setup.sh"
source "$REPO_DIR/lib/tmux/setup.sh"
source "$REPO_DIR/lib/deploy.sh"
source "$REPO_DIR/lib/ai/claude-code/setup.sh"
source "$REPO_DIR/lib/ai/codex/setup.sh"

# ───────────────────────────────────────────────────────
#  Termux 설정 (termux.properties)
# ───────────────────────────────────────────────────────
setup_termux_properties() {
  deploy_config "Termux 설정" "$SCRIPT_DIR/termux.properties" "$HOME/.termux/termux.properties"
}

# ───────────────────────────────────────────────────────
#  패키지 업데이트
# ───────────────────────────────────────────────────────
update_packages() {
  info "패키지 인덱스 업데이트 진행 중..."
  pkg update -y
  success "패키지 업데이트 완료"
}

# ───────────────────────────────────────────────────────
#  저장소 권한 설정
# ───────────────────────────────────────────────────────
setup_storage() {
  local storage_dir="$HOME/storage"

  if [[ -d "$storage_dir" ]]; then
    success "termux-setup-storage 이미 적용됨"
    return
  fi

  if command -v termux-setup-storage >/dev/null 2>&1; then
    info "termux-setup-storage 실행 중... (권한 팝업 승인 필요)"
    termux-setup-storage
    success "저장소 권한 설정 완료"
  else
    warn "termux-setup-storage 명령을 찾지 못해 저장소 권한 설정을 스킵합니다"
  fi
}

# ───────────────────────────────────────────────────────
#  패키지 설치
# ───────────────────────────────────────────────────────
install_packages() {
  local packages=(
    git
    zsh
    vim
    neovim
    fastfetch
    openssh
    wget
    curl
    tmux
    ripgrep
    starship
    lazygit
    unzip
    nodejs
  )

  for pkg_name in "${packages[@]}"; do
    if dpkg -s "$pkg_name" >/dev/null 2>&1; then
      success "$pkg_name 이미 설치됨"
    else
      info "$pkg_name 설치 중..."
      pkg install -y "$pkg_name"
      success "$pkg_name 설치 완료"
    fi
  done
}

# ───────────────────────────────────────────────────────
#  폰트 설치
# ───────────────────────────────────────────────────────
install_font() {
  local font_name="CaskaydiaMonoNerdFont-Regular"
  local dst="$HOME/.termux/font.ttf"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip"

  local url_hash
  url_hash="$(printf '%s' "$url" | md5sum | cut -d' ' -f1)"
  local src="$HOME/.termux/.font-${font_name}-${url_hash}.ttf"

  if [[ ! -f "$src" ]]; then
    local tmp_dir
    tmp_dir="$(mktemp -d)"

    info "CaskaydiaMono Nerd Font 다운로드 중..."
    curl -fsSL -o "$tmp_dir/CascadiaMono.zip" "$url"
    unzip -qo "$tmp_dir/CascadiaMono.zip" "${font_name}.ttf" -d "$tmp_dir"

    mkdir -p "$HOME/.termux"
    cp "$tmp_dir/${font_name}.ttf" "$src"
    rm -rf "$tmp_dir"
  fi

  deploy_config "Nerd Font" "$src" "$dst"
}

# ───────────────────────────────────────────────────────
#  기본 셸 변경
# ───────────────────────────────────────────────────────
change_shell_to_zsh() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    success "기본 셸이 이미 zsh임"
    return
  fi

  if command -v chsh >/dev/null 2>&1; then
    info "기본 셸을 zsh로 변경 중..."
    if chsh -s "$zsh_path"; then
      success "기본 셸 변경 완료"
    else
      warn "chsh 실행 실패. Termux 재시작 후 수동으로 zsh 실행하세요"
    fi
  else
    warn "chsh 명령이 없어 기본 셸 변경을 스킵합니다"
  fi
}

# ───────────────────────────────────────────────────────
#  메인 실행
# ───────────────────────────────────────────────────────
main() {
  ensure_termux

  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo -e "${BLUE}  Termux 환경 초기 세팅${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo ""

  section "패키지 업데이트"
  update_packages

  section "저장소 권한"
  setup_storage

  section "패키지 설치"
  install_packages

  section "Oh My Zsh"
  install_oh_my_zsh
  setup_zshrc

  section "Starship"
  setup_starship_config

  section "폰트"
  install_font

  section "셸 기본값"
  change_shell_to_zsh

  section "tmux"
  setup_tmux

  section "Termux 설정"
  setup_termux_properties

  section "AI CLI"
  install_claude_code
  setup_claude_commands
  install_codex

  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  ✔ 세팅 완료!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  설치된 구성:"
  echo -e "    프롬프트 → Starship"
  echo -e "    셸       → Oh My Zsh (자동제안, 구문강조, 자동완성)"
  echo -e "    폰트     → CaskaydiaMono Nerd Font"
  echo -e "    CLI 도구 → git, zsh, vim, neovim, fastfetch, openssh, wget, curl, tmux, ripgrep, starship, lazygit, nodejs"
  echo -e "    Termux   → 한글 입력, 추가 키 커스터마이징"
  echo -e "    AI CLI   → Claude Code, Codex CLI"
  echo -e "    tmux     → 설정 + 셸 함수"
  echo ""
  echo -e "  ${YELLOW}※ 일부 설정은 Termux 앱 재시작 후 반영됩니다.${NC}"
  echo ""
}

main "$@"
