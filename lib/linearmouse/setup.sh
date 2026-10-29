#!/usr/bin/env bash

_LINEARMOUSE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_LINEARMOUSE_DIR/../deploy.sh"

# ───────────────────────────────────────────────────────
#  LinearMouse 설치
# ───────────────────────────────────────────────────────
install_linearmouse() {
  if [[ -d "/Applications/LinearMouse.app" ]] || brew list --cask linearmouse &>/dev/null; then
    success "LinearMouse 이미 설치됨"
  else
    info "LinearMouse 설치 중..."
    brew install --cask linearmouse
    success "LinearMouse 설치 완료"
  fi
}

# ───────────────────────────────────────────────────────
#  LinearMouse 설정 (마우스만 수평/수직 스크롤 반전, 메뉴 막대 아이콘 숨김)
# ───────────────────────────────────────────────────────
setup_linearmouse_config() {
  deploy_config "LinearMouse 설정" "$_LINEARMOUSE_DIR/linearmouse.json" "$HOME/.config/linearmouse/linearmouse.json"

  local lm="com.lujjjh.LinearMouse"
  if [[ "$(defaults read "$lm" showInMenuBar 2>/dev/null)" == "0" ]]; then
    success "LinearMouse 메뉴 막대 아이콘 이미 숨김"
  else
    info "LinearMouse 메뉴 막대 아이콘 숨기는 중..."
    # 첫 실행 전엔 showInMenuBar가 menuBarVisibilityMode로 마이그레이션되고, 이후엔 menuBarVisibilityMode만 읽음
    defaults write "$lm" showInMenuBar -bool false
    defaults write "$lm" menuBarVisibilityMode -string '"never"'
    success "LinearMouse 메뉴 막대 아이콘 숨김 완료"
  fi
}

# ───────────────────────────────────────────────────────
#  자연스러운 스크롤 (LinearMouse 반전은 시스템 방향 기준)
# ───────────────────────────────────────────────────────
setup_natural_scrolling() {
  if [[ "$(defaults read -g com.apple.swipescrolldirection 2>/dev/null)" != "0" ]]; then
    success "자연스러운 스크롤 이미 활성화됨"
  else
    info "자연스러운 스크롤 활성화..."
    defaults write -g com.apple.swipescrolldirection -bool true
    success "자연스러운 스크롤 활성화 완료 (로그아웃 후 적용)"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_linearmouse
  setup_linearmouse_config
  setup_natural_scrolling
fi
