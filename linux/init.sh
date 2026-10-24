#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$REPO_DIR/lib/platform.sh"
source "$REPO_DIR/lib/zsh/setup.sh"
source "$REPO_DIR/lib/starship/setup.sh"
source "$REPO_DIR/lib/tmux/setup.sh"
source "$REPO_DIR/lib/ai/claude-code/setup.sh"
source "$REPO_DIR/lib/ai/codex/setup.sh"
source "$REPO_DIR/lib/mise/setup.sh"
source "$REPO_DIR/lib/docker/setup.sh"

# ───────────────────────────────────────────────────────
#  패키지 업데이트
# ───────────────────────────────────────────────────────
update_packages() {
  info "패키지 인덱스 업데이트 진행 중..."
  sudo apt-get update
  success "패키지 업데이트 완료"
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
    tmux
    curl
    wget
    ripgrep
    unzip
    jq
    starship
    lazygit
    btop
    locales
  )

  for pkg_name in "${packages[@]}"; do
    if dpkg -s "$pkg_name" >/dev/null 2>&1; then
      success "$pkg_name 이미 설치됨"
    else
      info "$pkg_name 설치 중..."
      sudo apt-get install -y "$pkg_name"
      success "$pkg_name 설치 완료"
    fi
  done
}

# ───────────────────────────────────────────────────────
#  한국어 로케일 생성 (macOS ssh가 LANG=ko_KR.UTF-8을 넘기고 tmux 함수도 사용)
# ───────────────────────────────────────────────────────
setup_locale() {
  if locale -a 2>/dev/null | grep -qi '^ko_KR\.utf-\?8$'; then
    success "ko_KR.UTF-8 로케일 이미 생성됨"
    return
  fi

  info "ko_KR.UTF-8 로케일 생성 중..."
  # Debian은 locale-gen 인자를 무시하고 /etc/locale.gen만 읽음
  if [[ -f /etc/locale.gen ]]; then
    sudo sed -i 's/^# *\(ko_KR\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  fi
  sudo locale-gen ko_KR.UTF-8
  success "ko_KR.UTF-8 로케일 생성 완료"
}

# ───────────────────────────────────────────────────────
#  기본 셸 변경
# ───────────────────────────────────────────────────────
change_shell_to_zsh() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$zsh_path" ]]; then
    success "기본 셸이 이미 zsh임"
    return
  fi

  info "기본 셸을 zsh로 변경 중..."
  sudo chsh -s "$zsh_path" "$USER"
  success "기본 셸 변경 완료 (재로그인 후 적용)"
}

# ───────────────────────────────────────────────────────
#  메인 실행
# ───────────────────────────────────────────────────────
main() {
  ensure_linux

  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo -e "${BLUE}  Linux 환경 초기 세팅${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo ""

  section "패키지 업데이트"
  update_packages

  section "패키지 설치"
  install_packages

  section "로케일"
  setup_locale

  section "Oh My Zsh"
  install_oh_my_zsh
  setup_zshrc

  section "Starship"
  setup_starship_config

  section "셸 기본값"
  change_shell_to_zsh

  section "tmux"
  setup_tmux

  section "mise"
  install_mise
  setup_mise_runtimes
  setup_mise_settings

  section "Docker"
  install_docker_engine

  section "AI CLI"
  install_claude_code
  setup_claude_skills
  setup_claude_instructions
  install_codex
  setup_codex_skills
  setup_codex_instructions

  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  ✔ 세팅 완료!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  설치된 구성:"
  echo -e "    프롬프트 → Starship"
  echo -e "    셸       → Oh My Zsh"
  echo -e "    CLI 도구 → git, zsh, vim, neovim, tmux, curl, wget, ripgrep, unzip, jq, lazygit, btop"
  echo -e "    런타임   → mise (rust, uv, java, maven, kotlin, node, go)"
  echo -e "    컨테이너 → Docker Engine, Docker Compose, Buildx"
  echo -e "    AI CLI   → Claude Code, Codex CLI (전역 지시사항 포함)"
  echo -e "    tmux     → 설정 + 셸 함수"
  echo ""
  echo -e "  ${YELLOW}※ 기본 셸(zsh)과 docker 그룹은 재로그인 후 반영됩니다.${NC}"
  echo ""
}

main "$@"
