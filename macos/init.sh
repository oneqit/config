#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYBINDING_DIR="$SCRIPT_DIR/keybinding"
source "$REPO_DIR/lib/platform.sh"
source "$REPO_DIR/lib/zsh/setup.sh"
source "$REPO_DIR/lib/starship/setup.sh"
source "$REPO_DIR/lib/tmux/setup.sh"
source "$REPO_DIR/lib/ghostty/setup.sh"
source "$REPO_DIR/lib/karabiner/setup.sh"
source "$REPO_DIR/lib/ai/claude-code/setup.sh"
source "$REPO_DIR/lib/ai/codex/setup.sh"

# ───────────────────────────────────────────────────────
#  Homebrew 설치
# ───────────────────────────────────────────────────────
install_homebrew() {
  if command -v brew &>/dev/null; then
    success "Homebrew 이미 설치됨"
  else
    info "Homebrew 설치 중..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon Mac PATH 설정
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    success "Homebrew 설치 완료"
  fi

  brew update
}

# ───────────────────────────────────────────────────────
#  패키지 설치
# ───────────────────────────────────────────────────────
install_packages() {
  # brew패키지:커맨드명
  local packages=(
    "git:git"
    "git-flow-avh:git-flow"
    "neovim:nvim"
    "tmux:tmux"
    "starship:starship"
    "ripgrep:rg"
    "btop:btop"
    "lazygit:lazygit"
    "lazydocker:lazydocker"
    "k9s:k9s"
    "colima:colima"
    "docker-credential-helper:docker-credential-osxkeychain"
  )

  for entry in "${packages[@]}"; do
    local pkg="${entry%%:*}"
    local cmd="${entry#*:}"
    if command -v "$cmd" &>/dev/null; then
      success "$pkg 이미 설치됨"
    else
      info "$pkg 설치 중..."
      brew install "$pkg"
      success "$pkg 설치 완료"
    fi
  done
}

# ───────────────────────────────────────────────────────
#  Font 설치
# ───────────────────────────────────────────────────────
install_font() {
  local fonts=(
    font-caskaydia-mono-nerd-font
    font-noto-sans-mono-cjk-kr
  )

  for font in "${fonts[@]}"; do
    if brew list --cask "$font" &>/dev/null; then
      success "$font 이미 설치됨"
    else
      info "$font 설치 중..."
      brew install --cask "$font"
      success "$font 설치 완료"
    fi
  done
}

# ───────────────────────────────────────────────────────
#  앱 설치
# ───────────────────────────────────────────────────────
install_apps() {
  # cask명:앱이름
  local apps=(
    "rectangle:Rectangle"
    "scroll-reverser:Scroll Reverser"
  )

  for entry in "${apps[@]}"; do
    local cask="${entry%%:*}"
    local app_name="${entry#*:}"
    if [[ -d "/Applications/$app_name.app" ]] || brew list --cask "$cask" &>/dev/null; then
      success "$app_name 이미 설치됨"
    else
      info "$app_name 설치 중..."
      brew install --cask "$cask"
      success "$app_name 설치 완료"
    fi
  done
}

# ───────────────────────────────────────────────────────
#  macOS 기본 설정
# ───────────────────────────────────────────────────────
setup_macos_defaults() {
  if [[ "$(defaults read -g ApplePressAndHoldEnabled 2>/dev/null)" == "0" ]]; then
    success "키 반복 입력 이미 활성화됨"
  else
    info "키 반복 입력 활성화..."
    defaults write -g ApplePressAndHoldEnabled -bool false
    success "키 반복 입력 활성화 완료"
  fi
}

# ───────────────────────────────────────────────────────
#  Scroll Reverser 설정
# ───────────────────────────────────────────────────────
setup_scroll_reverser() {
  local sr="com.pilotmoon.scroll-reverser"
  if [[ "$(defaults read "$sr" ReverseMouse 2>/dev/null)" == "1" ]]; then
    success "Scroll Reverser 이미 설정됨"
  else
    info "Scroll Reverser 설정 중..."
    defaults write "$sr" ReverseMouse -bool true
    defaults write "$sr" ReverseTrackpad -bool false
    defaults write "$sr" ReverseX -bool true
    defaults write "$sr" ReverseY -bool true
    defaults write "$sr" HideIcon -bool true
    success "Scroll Reverser 설정 완료 (마우스 수평/수직 반전, 아이콘 숨김)"
  fi
}

# ───────────────────────────────────────────────────────
#  한영 키보드 백틱(`) 입력 설정
# ───────────────────────────────────────────────────────
setup_keybinding() {
  deploy_config "백틱 설정" "$KEYBINDING_DIR/DefaultkeyBinding.dict" "$HOME/Library/KeyBindings/DefaultkeyBinding.dict"
}

# ───────────────────────────────────────────────────────
#  메인 실행
# ───────────────────────────────────────────────────────
main() {
  ensure_macos

  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo -e "${BLUE}  macOS 환경 초기 세팅${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo ""

  section "Homebrew"
  install_homebrew

  section "패키지"
  install_packages

  section "폰트"
  install_font

  section "앱"
  install_apps

  section "마우스"
  setup_scroll_reverser

  section "키보드"
  setup_macos_defaults
  setup_keybinding

  section "Karabiner"
  install_karabiner
  setup_karabiner_config

  section "Ghostty"
  install_ghostty
  setup_ghostty_config

  section "Oh My Zsh"
  install_oh_my_zsh
  setup_zshrc

  section "Starship"
  setup_starship_config

  section "tmux"
  setup_tmux

  section "AI CLI"
  install_claude_code
  install_codex

  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  ✔ 세팅 완료!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  설치된 구성:"
  echo -e "    터미널   → Ghostty"
  echo -e "    프롬프트 → Starship"
  echo -e "    셸       → Oh My Zsh (자동제안, 구문강조, 자동완성)"
  echo -e "    폰트     → CaskaydiaMono Nerd Font, Noto Sans Mono CJK KR"
  echo -e "    앱       → Rectangle, Scroll Reverser"
  echo -e "    CLI 도구 → git-flow-avh, neovim, tmux, ripgrep, btop, lazygit, lazydocker, k9s"
  echo -e "    컨테이너 → colima, docker-credential-helper"
  echo -e "    AI CLI   → Claude Code, Codex CLI"
  echo -e "    키보드   → 키 반복 입력, 한영 백틱(\`), Karabiner (⌥R→F18)"
  echo -e "    tmux     → 설정 + 셸 함수"
  echo ""
  echo -e "  ${YELLOW}[!] 수동 설정 필요:${NC}"
  echo -e "    Scroll Reverser → 활성화, 로그인 시 시작"
  echo -e "    Karabiner → Simple Modifications에서 right_command → F18 추가"
  echo -e "    Rectangle → 로그인 시 실행, 메뉴 막대 아이콘 숨김"
  echo -e "    시스템 설정 → 키보드"
  echo -e "      → 키 반복 속도, 반복 지연 시간 조정"
  echo -e "      → 키보드 단축키 → 입력 소스 → 이전 입력 소스 → F18로 변경"
  echo -e "      → 텍스트 입력 설정 조정"
  echo ""
}

main "$@"
