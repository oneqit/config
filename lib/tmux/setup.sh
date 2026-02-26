#!/usr/bin/env bash

_TMUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_TMUX_DIR/../deploy.sh"
source "$_TMUX_DIR/../platform.sh"

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

  # 컴파일 (소스가 바이너리보다 새로우면 재컴파일)
  local need_compile=false
  if [[ ! -x "$bin_path" ]]; then
    need_compile=true
  elif [[ "$swift_src" -nt "$bin_path" ]]; then
    need_compile=true
  fi

  if $need_compile; then
    mkdir -p "$bin_dir"
    info "tmux-im-status 컴파일 중..."
    swiftc "$swift_src" -o "$bin_path"
    success "tmux-im-status 컴파일 완료 → \"$bin_path\""
  else
    success "tmux-im-status 변경 없음 → 스킵"
  fi

  # plist 배포 (__HOME__ → $HOME 치환)
  if [[ -f "$plist_dst" ]]; then
    success "plist 이미 배포됨 → 스킵"
  else
    mkdir -p "$(dirname "$plist_dst")"
    sed "s|__HOME__|$HOME|g" "$plist_src" > "$plist_dst"
    success "plist 배포 완료 → \"$plist_dst\""
  fi

  # 서비스 등록/재시작 (재컴파일 시 재시작)
  if $need_compile && launchctl list "$service_label" &>/dev/null; then
    launchctl stop "$service_label"
    launchctl start "$service_label"
    success "tmux-im-status 서비스 재시작 완료"
  elif launchctl list "$service_label" &>/dev/null; then
    success "tmux-im-status 서비스 이미 로드됨 → 스킵"
  else
    launchctl load "$plist_dst"
    success "tmux-im-status 서비스 로드 완료"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_tmux
  is_macos && setup_tmux_im_status
fi
