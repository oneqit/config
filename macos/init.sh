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
  info "패키지 설치 중..."

  local packages=(
    git           # 버전 관리
    git-flow-avh  # Git 브랜치 워크플로우
    neovim        # 텍스트 에디터
    tmux          # 세션/분할 관리
    starship      # 프롬프트
    ripgrep       # 빠른 검색 (rg)
    btop          # 시스템 모니터링
    lazygit       # Git TUI
    lazydocker    # Docker TUI
    k9s           # Kubernetes TUI
    colima        # docker 컨테이너 런타임
    docker-credential-helper  # colima + Docker 자격증명 관리
  )

  for pkg in "${packages[@]}"; do
    if brew list "$pkg" &>/dev/null; then
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
    font-caskaydia-cove-nerd-font
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
#  Ghostty 설치
# ───────────────────────────────────────────────────────
install_ghostty() {
  if brew list --cask ghostty &>/dev/null; then
    success "Ghostty 이미 설치됨"
  else
    info "Ghostty 설치 중..."
    brew install --cask ghostty
    success "Ghostty 설치 완료"
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

  section "Ghostty"
  install_ghostty
  setup_ghostty_config

  section "Oh My Zsh"
  install_oh_my_zsh
  setup_zshrc

  section "Starship"
  setup_starship_config

  section "키보드"
  setup_keybinding

  section "tmux"
  setup_tmux

  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  ✔ 세팅 완료!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  설치된 구성:"
  echo -e "    터미널   → Ghostty"
  echo -e "    프롬프트 → Starship"
  echo -e "    셸       → Oh My Zsh (자동제안, 구문강조, 자동완성)"
  echo -e "    폰트     → CaskaydiaCove Nerd Font, Noto Sans Mono CJK KR"
  echo -e "    CLI 도구 → git-flow-avh, neovim, tmux, ripgrep, btop, lazygit, lazydocker, k9s"
  echo -e "    컨테이너 → colima, docker-credential-helper"
  echo -e "    키보드   → 한영 백틱(\`) 설정"
  echo -e "    tmux     → 설정 + 셸 함수"
  echo ""
}

main "$@"
