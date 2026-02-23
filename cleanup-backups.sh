#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logging.sh"

# ───────────────────────────────────────────────────────
#  백업 파일 정리
#  init.sh 실행 시 생성된 백업 파일을 일괄 삭제
# ───────────────────────────────────────────────────────

# init.sh가 생성하는 백업 파일의 정확한 경로 패턴
BACKUP_PATTERNS=(
  "$HOME/Library/KeyBindings/DefaultkeyBinding.dict.backup."*
  "$HOME/.config/starship.toml.backup."*
  "$HOME/.tmux.conf.backup."*
  "$HOME/.zshrc.backup."*
  "$HOME/Library/Application Support/com.mitchellh.ghostty/config.backup."*
  "$HOME/.claude/commands.backup."*
)

main() {
  local dry_run=false
  [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]] && dry_run=true

  local targets=()

  for pattern in "${BACKUP_PATTERNS[@]}"; do
    # glob이 매칭되지 않으면 패턴 문자열 그대로 남으므로 존재 여부 확인
    [[ -e "$pattern" ]] && targets+=("$pattern")
  done

  if [[ ${#targets[@]} -eq 0 ]]; then
    success "정리할 백업 파일이 없습니다"
    return
  fi

  echo ""
  if $dry_run; then
    info "[dry-run] 삭제 대상 백업 (${#targets[@]}개):"
  else
    info "발견된 백업 (${#targets[@]}개):"
  fi
  echo ""
  for t in "${targets[@]}"; do
    if [[ -d "$t" ]]; then
      echo "  $t  (디렉토리)"
    else
      echo "  $t"
    fi
  done
  echo ""

  if $dry_run; then
    info "dry-run 모드 — 실제 삭제하지 않습니다"
    return
  fi

  read -rp $'  \033[1;33m[!]\033[0m 모두 삭제하시겠습니까? [y/N] ' answer
  echo ""

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    for t in "${targets[@]}"; do
      rm -rf "$t"
    done
    success "백업 ${#targets[@]}개 삭제 완료"
  else
    info "취소되었습니다"
  fi
}

main "$@"
