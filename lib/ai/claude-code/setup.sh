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
#  Claude Code Skills 심링크 설정
# ───────────────────────────────────────────────────────
setup_claude_skills() {
  local src_root="$_CLAUDE_CODE_DIR/skills"
  local dst_root="$HOME/.claude/skills"
  local src_skill
  local dst_skill
  local skill_name
  local linked_count=0
  local kept_count=0
  local skipped_count=0
  local removed_count=0
  local target

  src_root="$(cd "$src_root" && pwd)"
  mkdir -p "$HOME/.claude"

  # Legacy migration: previous versions linked ~/.claude/skills to this repo.
  # Replace that root symlink with a real directory to preserve other skills.
  if [[ -L "$dst_root" ]] && [[ "$(readlink "$dst_root")" == "$src_root" ]]; then
    warn "기존 Claude Skills 전체 심링크 감지, 개별 스킬 링크 방식으로 전환"
    mv "$dst_root" "${dst_root}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  mkdir -p "$dst_root"

  for src_skill in "$src_root"/*; do
    [[ -d "$src_skill" ]] || continue
    skill_name="$(basename "$src_skill")"
    dst_skill="$dst_root/$skill_name"

    if [[ -L "$dst_skill" ]] && [[ "$(readlink "$dst_skill")" == "$src_skill" ]]; then
      kept_count=$((kept_count + 1))
      continue
    fi

    if [[ -L "$dst_skill" ]] || [[ -e "$dst_skill" ]]; then
      warn "Claude Skills 이름 충돌로 스킵: $dst_skill"
      skipped_count=$((skipped_count + 1))
      continue
    fi

    if ln -s "$src_skill" "$dst_skill"; then
      linked_count=$((linked_count + 1))
    else
      error "Claude Skills 연결 실패: $dst_skill"
    fi
  done

  # 레포에서 사라진 스킬에 대한 stale 심링크 정리
  for dst_skill in "$dst_root"/*; do
    [[ -L "$dst_skill" ]] || continue
    target="$(readlink "$dst_skill")"
    case "$target" in
      "$src_root"/*)
        if [[ ! -e "$target" ]]; then
          warn "Claude Skills stale 심링크 제거: $dst_skill"
          rm "$dst_skill"
          removed_count=$((removed_count + 1))
        fi
        ;;
    esac
  done

  success "Claude Skills 연결 완료 (신규: $linked_count, 유지: $kept_count, 스킵: $skipped_count, 제거: $removed_count)"
}

# ───────────────────────────────────────────────────────
#  Claude Code 전역 지시사항 심링크 설정
# ───────────────────────────────────────────────────────
setup_claude_instructions() {
  local src="$_CLAUDE_CODE_DIR/CLAUDE.md"
  local dst="$HOME/.claude/CLAUDE.md"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    success "Claude 전역 지시사항 이미 연결됨"
    return
  fi

  mkdir -p "$HOME/.claude"
  [[ -f "$dst" && ! -L "$dst" ]] && cp "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  ln -sf "$src" "$dst"
  success "Claude 전역 지시사항 연결 완료"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_claude_code
  setup_claude_skills
  setup_claude_instructions
fi
