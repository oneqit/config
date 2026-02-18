#!/usr/bin/env bash

_CLAUDE_CODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_CLAUDE_CODE_DIR/../../logging.sh"
source "$_CLAUDE_CODE_DIR/../../platform.sh"

# ───────────────────────────────────────────────────────
#  Claude Code 설치
# ───────────────────────────────────────────────────────
install_claude_code() {
  if command -v claude &>/dev/null; then
    success "Claude Code 이미 설치됨"
    return
  fi

  info "Claude Code 설치 중..."
  if is_macos; then
    curl -fsSL https://claude.ai/install.sh | bash
  else
    npm install -g @anthropic-ai/claude-code
  fi
  success "Claude Code 설치 완료"
}

# ───────────────────────────────────────────────────────
#  Claude Code 명령어 심링크 설정
# ───────────────────────────────────────────────────────
setup_claude_commands() {
  local src_dir="$_CLAUDE_CODE_DIR/../../../.claude/commands"
  local dst="$HOME/.claude/commands"

  src_dir="$(cd "$src_dir" && pwd)"
  mkdir -p "$HOME/.claude"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src_dir" ]]; then
    success "Claude 명령어 이미 연결됨"
    return
  fi

  if [[ -e "$dst" ]]; then
    warn "Claude 명령어 기존 경로 백업"
    mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  ln -s "$src_dir" "$dst"
  success "Claude 명령어 연결 완료 → $dst"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_claude_code
  setup_claude_commands
fi
