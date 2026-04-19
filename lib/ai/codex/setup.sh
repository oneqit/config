#!/usr/bin/env bash

_CODEX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_CODEX_DIR/../../logging.sh"
source "$_CODEX_DIR/../../platform.sh"

# ───────────────────────────────────────────────────────
#  Codex CLI 설치
# ───────────────────────────────────────────────────────
install_codex() {
  if command -v codex &>/dev/null; then
    success "Codex CLI 이미 설치됨"
    return
  fi

  info "Codex CLI 설치 중..."
  if is_macos; then
    brew install codex
  else
    npm install -g @openai/codex
  fi
  success "Codex CLI 설치 완료"
}

# ───────────────────────────────────────────────────────
#  Codex Skills 심링크 설정
# ───────────────────────────────────────────────────────
setup_codex_skills() {
  local src_root="$_CODEX_DIR/skills"
  local dst_root="$HOME/.codex/skills"
  local src_skill
  local dst_skill
  local skill_name
  local linked_count=0
  local kept_count=0
  local skipped_count=0
  local removed_count=0
  local target

  src_root="$(cd "$src_root" && pwd)"
  mkdir -p "$HOME/.codex"

  # Legacy migration: previous versions linked ~/.codex/skills to this repo.
  # Replace that root symlink with a real directory to preserve Codex .system skills.
  if [[ -L "$dst_root" ]] && [[ "$(readlink "$dst_root")" == "$src_root" ]]; then
    warn "기존 Codex Skills 전체 심링크 감지, 개별 스킬 링크 방식으로 전환"
    mv "$dst_root" "${dst_root}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  mkdir -p "$dst_root"

  for src_skill in "$src_root"/*; do
    [[ -d "$src_skill" ]] || continue
    skill_name="$(basename "$src_skill")"
    dst_skill="$dst_root/$skill_name"

    if [[ -L "$dst_skill" ]] && [[ "$(readlink "$dst_skill")" == "$src_skill" ]]; then
      ((kept_count++))
      continue
    fi

    if [[ -L "$dst_skill" ]] || [[ -e "$dst_skill" ]]; then
      warn "Codex Skills 이름 충돌로 스킵: $dst_skill"
      ((skipped_count++))
      continue
    fi

    if ln -s "$src_skill" "$dst_skill"; then
      ((linked_count++))
    else
      error "Codex Skills 연결 실패: $dst_skill"
    fi
  done

  # 레포에서 사라진 스킬에 대한 stale 심링크 정리
  for dst_skill in "$dst_root"/*; do
    [[ -L "$dst_skill" ]] || continue
    target="$(readlink "$dst_skill")"
    case "$target" in
      "$src_root"/*)
        if [[ ! -e "$target" ]]; then
          warn "Codex Skills stale 심링크 제거: $dst_skill"
          rm "$dst_skill"
          ((removed_count++))
        fi
        ;;
    esac
  done

  success "Codex Skills 연결 완료 (신규: $linked_count, 유지: $kept_count, 스킵: $skipped_count, 제거: $removed_count)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_codex
  setup_codex_skills
fi
