#!/usr/bin/env bash

_DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_DEPLOY_DIR/logging.sh"

# deploy_config <label> <src> <dst>
deploy_config() {
  local label="$1" src="$2" dst="$3"

  mkdir -p "$(dirname "$dst")"

  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    success "$label 변경 없음 → 스킵"
    return
  fi

  if [[ -f "$dst" ]]; then
    warn "$label 이미 존재 → 백업 후 덮어쓰기"
    cp "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  info "$label 적용 중..."
  cp "$src" "$dst"
  success "$label 적용 완료 → \"$dst\""
}
