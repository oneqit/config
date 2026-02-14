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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_claude_code
fi
