#!/data/data/com.termux/files/usr/bin/bash
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
section() { echo ""; echo -e "${BLUE}── $1${NC}"; }

# ───────────────────────────────────────────────────────
#  Termux 환경 확인
# ───────────────────────────────────────────────────────
ensure_termux() {
  if [[ -z "${PREFIX:-}" || "${PREFIX}" != "/data/data/com.termux/files/usr" ]]; then
    error "이 스크립트는 Termux 환경에서 실행해야 합니다"
  fi
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
    extras=$(sed -n "/${extras_marker}/,\$p" "$zshrc" | tail -n +3 | sed '/./,$!d')
  fi

  tmp_file="$(mktemp)"
  cp "$TEMPLATE_DIR/.zshrc" "$tmp_file"
  if [[ -n "$extras" ]]; then
    printf '\n%s\n' "$extras" >> "$tmp_file"
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

# ───────────────────────────────────────────────────────
#  Starship 설정
# ───────────────────────────────────────────────────────
setup_starship_config() {
  local config_dir="$HOME/.config"
  local config_file="$config_dir/starship.toml"

  mkdir -p "$config_dir"

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
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo -e "${BLUE}  Termux 환경 초기 세팅${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo ""

  section "환경 확인"
  ensure_termux

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

  section "셸 기본값"
  change_shell_to_zsh

  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  ✔ 세팅 완료!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  설치된 구성:"
  echo -e "    프롬프트 → Starship"
  echo -e "    셸       → Oh My Zsh (자동제안, 구문강조, 자동완성)"
  echo -e "    CLI 도구 → git, zsh, vim, neovim, fastfetch, openssh, wget, curl, tmux, ripgrep, starship, lazygit"
  echo ""
  echo -e "  ${YELLOW}※ 일부 설정은 Termux 앱 재시작 후 반영됩니다.${NC}"
  echo ""
}

main "$@"
