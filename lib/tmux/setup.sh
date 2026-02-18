#!/usr/bin/env bash

_TMUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_TMUX_DIR/../deploy.sh"

# ───────────────────────────────────────────────────────
#  tmux 설정
# ───────────────────────────────────────────────────────
setup_tmux() {
  deploy_config "tmux 설정" "$_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
}

# ───────────────────────────────────────────────────────
#  tmux 입력기 상태 표시 데몬 (macOS 전용)
# ───────────────────────────────────────────────────────
setup_tmux_im_status() {
  local bin_dir="$HOME/.local/bin"
  local bin_path="$bin_dir/tmux-im-status"
  local swift_src="$_TMUX_DIR/tmux-im-status.swift"
  local plist_src="$_TMUX_DIR/com.oneq.tmux-im-status.plist"
  local plist_dst="$HOME/Library/LaunchAgents/com.oneq.tmux-im-status.plist"
  local service_label="com.oneq.tmux-im-status"

  # 컴파일
  mkdir -p "$bin_dir"
  info "tmux-im-status 컴파일 중..."
  swiftc "$swift_src" -o "$bin_path"
  success "tmux-im-status 컴파일 완료 → \"$bin_path\""

  # plist 배포 (__HOME__ → $HOME 치환)
  mkdir -p "$(dirname "$plist_dst")"
  sed "s|__HOME__|$HOME|g" "$plist_src" > "$plist_dst"
  success "plist 배포 완료 → \"$plist_dst\""

  # launchctl 서비스 등록
  if launchctl list "$service_label" &>/dev/null; then
    info "기존 서비스 언로드 중..."
    launchctl unload "$plist_dst" 2>/dev/null || true
  fi
  launchctl load "$plist_dst"
  success "tmux-im-status 서비스 로드 완료"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_tmux
  setup_tmux_im_status
fi
