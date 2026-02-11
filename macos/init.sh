#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

# ───────────────────────────────────────────────────────
#  색상 정의
# ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "  ${BLUE}[i]${NC} $1"; }
success() { echo -e "  ${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "  ${YELLOW}[!]${NC} $1"; }
error()   { echo -e "  ${RED}[✘]${NC} $1"; exit 1; }
section() { echo "" ; echo -e "${BLUE}── $1${NC}"; }

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
    font-cascadia-mono-nf
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
#  Ghostty 설정
# ───────────────────────────────────────────────────────
setup_ghostty_config() {
  local config_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  local config_file="$config_dir/config"

  mkdir -p "$config_dir"

  if [[ -f "$config_file" ]] && cmp -s "$TEMPLATE_DIR/ghostty.config" "$config_file"; then
    success "Ghostty 설정 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$config_file" ]]; then
    warn "Ghostty 설정 파일 이미 존재 → 백업 후 덮어쓰기"
    cp "$config_file" "${config_file}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "Ghostty 설정 파일 생성 중..."

  cp "$TEMPLATE_DIR/ghostty.config" "$config_file"

  success "Ghostty 설정 완료 → \"$config_file\""
}

# ───────────────────────────────────────────────────────
#  Oh My Zsh 설치
# ───────────────────────────────────────────────────────
install_oh_my_zsh() {
  local omz_dir="$HOME/.oh-my-zsh"

  if [[ -d "$omz_dir" ]]; then
    success "Oh My Zsh 이미 설치됨"
  else
    info "Oh My Zsh 설치 중..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
    if [[ ! -d "$dir" ]]; then
      git clone "https://github.com/$repo" "$dir"
    fi
  done
}

# ───────────────────────────────────────────────────────
#  .zshrc 설정
# ───────────────────────────────────────────────────────
setup_zshrc() {
  local zshrc="$HOME/.zshrc"

  # 기존 .zshrc에서 Extras 섹션 아래 사용자 설정 추출
  local extras=""
  if [[ -f "$zshrc" ]]; then
    local extras_marker="#  Extras"
    extras=$(sed -n "/${extras_marker}/,\$p" "$zshrc" | tail -n +3)
  fi

  if [[ -f "$zshrc" ]] && cmp -s "$zshrc" <(cat "$TEMPLATE_DIR/.zshrc"; [[ -n "$extras" ]] && echo "$extras"); then
    success ".zshrc 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$zshrc" ]]; then
    warn ".zshrc 이미 존재 → 백업"
    cp "$zshrc" "${zshrc}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info ".zshrc 생성 중..."

  cp "$TEMPLATE_DIR/.zshrc" "$zshrc"

  # Extras 섹션 아래 사용자 설정 복원
  if [[ -n "$extras" ]]; then
    echo "$extras" >> "$zshrc"
    success ".zshrc 설정 완료 → \"$zshrc\" (Extras 설정 유지됨)"
  else
    success ".zshrc 설정 완료 → \"$zshrc\""
  fi
}

# ───────────────────────────────────────────────────────
#  Starship 설정
# ───────────────────────────────────────────────────────
setup_starship_config() {
  local config_file="$HOME/.config/starship.toml"

  if [[ -f "$config_file" ]] && cmp -s "$TEMPLATE_DIR/starship.toml" "$config_file"; then
    success "Starship 설정 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$config_file" ]]; then
    warn "starship.toml 이미 존재 → 백업 후 덮어쓰기"
    cp "$config_file" "${config_file}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "Starship 설정 파일 생성 중..."

  cp "$TEMPLATE_DIR/starship.toml" "$config_file"

  success "Starship 설정 완료 → \"$config_file\""
}

# ───────────────────────────────────────────────────────
#  한영 키보드 백틱(`) 입력 설정
# ───────────────────────────────────────────────────────
setup_keybinding() {
  local keybinding_dir="$HOME/Library/KeyBindings"
  local keybinding_file="$keybinding_dir/DefaultkeyBinding.dict"

  if [[ -f "$keybinding_file" ]] && cmp -s "$TEMPLATE_DIR/DefaultkeyBinding.dict" "$keybinding_file"; then
    success "백틱 설정 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$keybinding_file" ]]; then
    warn "DefaultkeyBinding.dict 이미 존재 → 백업 후 덮어쓰기"
    cp "$keybinding_file" "${keybinding_file}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "한영 키보드 백틱 설정 중..."

  mkdir -p "$keybinding_dir"
  cp "$TEMPLATE_DIR/DefaultkeyBinding.dict" "$keybinding_file"

  success "백틱 설정 완료 → \"$keybinding_file\" (앱 재시작 후 적용)"
}

# ───────────────────────────────────────────────────────
#  메인 실행
# ───────────────────────────────────────────────────────
main() {
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
  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  ✔ 세팅 완료!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  설치된 구성:"
  echo -e "    터미널   → Ghostty"
  echo -e "    프롬프트 → Starship"
  echo -e "    셸       → Oh My Zsh (자동제안, 구문강조, 자동완성)"
  echo -e "    폰트     → Cascadia Mono NF, Noto Sans Mono CJK KR"
  echo -e "    CLI 도구 → git-flow-avh, tmux, ripgrep, btop, lazygit, lazydocker, k9s"
  echo -e "    컨테이너 → colima, docker-credential-helper"
  echo -e "    키보드   → 한영 백틱(\`) 설정"
  echo ""
}

main
