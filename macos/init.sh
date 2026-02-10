#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════
#  macOS 초기 개발 환경 세팅 스크립트
#
#  구성:
#    - Homebrew (패키지 매니저)
#    - Nerd Font (아이콘 폰트)
#    - Ghostty (터미널)
#    - tmux (세션/분할 관리)
#    - Oh My Zsh (Zsh 프레임워크)
#    - Starship (프롬프트)
#    - 한영 키보드 백틱 설정
#
#  사용법:
#    chmod +x setup.sh
#    ./setup.sh
# ═══════════════════════════════════════════════════════

# ───────────────────────────────────────────────────────
#  색상 정의
# ───────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }

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
    tmux          # 세션/분할 관리
    ripgrep       # 빠른 검색 (rg)
    starship      # 프롬프트
    colima        # 컨테이너 런타임
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
  local font_name="Cascadia Mono NF"

  if fc-list 2>/dev/null | grep -q "CascadiaMonoNF"; then
    success "Cascadia Mono NF 이미 설치됨"
  else
    info "Cascadia Code 폰트 설치 중..."
    brew install --cask font-cascadia-code
    success "Cascadia Mono NF 설치 완료"
  fi

  if fc-list 2>/dev/null | grep -q "NotoSansMonoCJKkr"; then
    success "Noto Sans Mono CJK KR 이미 설치됨"
  else
    info "Noto Sans Mono CJK KR 폰트 설치 중..."
    brew install --cask font-noto-sans-mono-cjk-kr
    success "Noto Sans Mono CJK KR 설치 완료"
  fi
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

  if [[ -f "$config_file" ]]; then
    warn "Ghostty 설정 파일 이미 존재 → 백업 후 덮어쓰기"
    cp "$config_file" "${config_file}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "Ghostty 설정 파일 생성 중..."

  cat > "$config_file" << 'EOF'
# ═══════════════════════════════════════
#  Ghostty 설정
# ═══════════════════════════════════════

# ─── 폰트 ───
font-family = Cascadia Mono NF
font-codepoint-map = U+AC00-U+D7AF,U+1100-U+11FF,U+3130-U+318F=Noto Sans Mono CJK KR
font-size = 12

# ─── 창 ───
window-padding-x = 2
window-padding-y = 2
window-decoration = true

# ─── 커서 ───
cursor-style = bar
cursor-style-blink = false

# ─── 기타 ───
copy-on-select = clipboard
confirm-close-surface = false
shell-integration = zsh

# ─── macOS 전용 ───
macos-option-as-alt = true
EOF

  success "Ghostty 설정 완료 → $config_file"
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

  # zsh-autosuggestions 플러그인
  local auto_dir="${ZSH_CUSTOM:-$omz_dir/custom}/plugins/zsh-autosuggestions"
  if [[ ! -d "$auto_dir" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$auto_dir"
  fi

  # zsh-syntax-highlighting 플러그인
  local syntax_dir="${ZSH_CUSTOM:-$omz_dir/custom}/plugins/zsh-syntax-highlighting"
  if [[ ! -d "$syntax_dir" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$syntax_dir"
  fi

  # zsh-completions 플러그인
  local comp_dir="${ZSH_CUSTOM:-$omz_dir/custom}/plugins/zsh-completions"
  if [[ ! -d "$comp_dir" ]]; then
    git clone https://github.com/zsh-users/zsh-completions "$comp_dir"
  fi
}

# ───────────────────────────────────────────────────────
#  .zshrc 설정
# ───────────────────────────────────────────────────────
setup_zshrc() {
  local zshrc="$HOME/.zshrc"

  if [[ -f "$zshrc" ]]; then
    warn ".zshrc 이미 존재 → 백업"
    cp "$zshrc" "${zshrc}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info ".zshrc 생성 중..."

  cat > "$zshrc" << 'ZSHRC'
# ═══════════════════════════════════════════════════════
#  .zshrc
# ═══════════════════════════════════════════════════════

# ─── Homebrew PATH (Apple Silicon) ───
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ═══════════════════════════════════════════════════════
#  Oh My Zsh
# ═══════════════════════════════════════════════════════
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source "$ZSH/oh-my-zsh.sh"

# ═══════════════════════════════════════════════════════
#  Starship
# ═══════════════════════════════════════════════════════
eval "$(starship init zsh)"

# ═══════════════════════════════════════════════════════
#  Extras
# ═══════════════════════════════════════════════════════
ZSHRC

  success ".zshrc 설정 완료"
}

# ───────────────────────────────────────────────────────
#  Starship 설정
# ───────────────────────────────────────────────────────
setup_starship_config() {
  local config_file="$HOME/.config/starship.toml"

  if [[ -f "$config_file" ]]; then
    warn "starship.toml 이미 존재 → 백업 후 덮어쓰기"
    cp "$config_file" "${config_file}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "Starship 설정 파일 생성 중..."

  cat > "$config_file" << 'EOF'
# ═══════════════════════════════════════
#  Starship 프롬프트 설정
# ═══════════════════════════════════════

# 프롬프트 포맷
format = """
$directory\
$git_branch\
$git_status\
$cmd_duration\
$line_break\
$character"""

# ─── 프롬프트 문자 ───
[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"

# ─── 디렉토리 ───
[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "bold cyan"

# ─── Git 브랜치 ───
[git_branch]
symbol = " "
style = "bold purple"

# ─── Git 상태 ───
[git_status]
format = '([$all_status$ahead_behind]($style) )'
style = "bold red"

# ─── 명령어 실행 시간 ───
[cmd_duration]
min_time = 500
format = "[⏱ $duration]($style) "
style = "bold yellow"
EOF

  success "Starship 설정 완료 → $config_file"
}

# ───────────────────────────────────────────────────────
#  한영 키보드 백틱(`) 입력 설정
# ───────────────────────────────────────────────────────
setup_keybinding() {
  local keybinding_dir="$HOME/Library/KeyBindings"
  local keybinding_file="$keybinding_dir/DefaultkeyBinding.dict"

  if [[ -f "$keybinding_file" ]]; then
    warn "DefaultkeyBinding.dict 이미 존재 → 백업 후 덮어쓰기"
    cp "$keybinding_file" "${keybinding_file}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "한영 키보드 백틱 설정 중..."

  mkdir -p "$keybinding_dir"
  cat > "$keybinding_file" << 'EOF'
{
    "₩" = ("insertText:", "`");
}
EOF

  success "백틱 설정 완료 → $keybinding_file (앱 재시작 후 적용)"
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

  install_homebrew
  install_packages
  install_font
  install_ghostty
  setup_ghostty_config
  install_oh_my_zsh
  setup_zshrc
  setup_starship_config
  setup_keybinding
  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  ✔ 세팅 완료!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  설치된 구성:"
  echo -e "    터미널   → Ghostty"
  echo -e "    프롬프트 → Starship"
  echo -e "    플러그인 → Oh My Zsh (git alias, 자동제안, 구문강조)"
  echo -e "    폰트     → Cascadia Mono NF"
  echo -e "    키보드   → 한영 백틱(\`) 설정"
  echo ""
}

main
