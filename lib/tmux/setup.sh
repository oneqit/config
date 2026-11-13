#!/usr/bin/env bash

_TMUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_TMUX_DIR/../deploy.sh"
source "$_TMUX_DIR/../platform.sh"

# ───────────────────────────────────────────────────────
#  tmux 설정
# ───────────────────────────────────────────────────────
setup_tmux() {
  deploy_config "tmux 설정" "$_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
  deploy_config "tmux-claude-fork" "$_TMUX_DIR/tmux-claude-fork" "$HOME/.local/bin/tmux-claude-fork"
  chmod +x "$HOME/.local/bin/tmux-claude-fork"
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
  local service_target="gui/$(id -u)/$service_label"

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
  local plist_changed=false
  if [[ -f "$plist_dst" ]] && sed "s|__HOME__|$HOME|g" "$plist_src" | cmp -s - "$plist_dst"; then
    success "plist 변경 없음 → 스킵"
  else
    mkdir -p "$(dirname "$plist_dst")"
    chmod 700 "$(dirname "$plist_dst")"
    info "디렉토리 생성 및 권한 설정 → \"$(dirname "$plist_dst")\" (700)"
    sed "s|__HOME__|$HOME|g" "$plist_src" > "$plist_dst"
    plist_changed=true
    success "plist 배포 완료 → \"$plist_dst\""
  fi

  # 서비스 등록/재시작 (plist 변경 시 재등록, 재컴파일 시 재시작)
  if ! launchctl print "$service_target" &>/dev/null; then
    launchctl bootstrap "gui/$(id -u)" "$plist_dst"
    success "tmux-im-status 서비스 등록 완료"
  elif $plist_changed; then
    launchctl bootout "$service_target"
    # bootout 직후 bootstrap하면 실패하므로 서비스가 내려갈 때까지 대기
    while launchctl print "$service_target" &>/dev/null; do sleep 0.1; done
    launchctl bootstrap "gui/$(id -u)" "$plist_dst"
    success "tmux-im-status 서비스 재등록 완료"
  elif $need_compile; then
    launchctl kickstart -k "$service_target"
    success "tmux-im-status 서비스 재시작 완료"
  else
    success "tmux-im-status 서비스 이미 등록됨 → 스킵"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_tmux
  is_macos && setup_tmux_im_status
  echo ""
  warn ".zshrc에 아래 설정이 필요합니다"
  info "  source \"$_TMUX_DIR/.zshrc.append\""
  info "  → .zshrc에 해당 설정이 있는지 확인해주세요"
fi
