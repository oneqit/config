#!/usr/bin/env bash

_MISE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MISE_DIR/../logging.sh"

# ───────────────────────────────────────────────────────
#  mise 설치
# ───────────────────────────────────────────────────────
install_mise() {
  if command -v mise &>/dev/null; then
    success "mise 이미 설치됨"
  else
    info "mise 설치 중..."
    brew install mise
    success "mise 설치 완료"
  fi
}

# ───────────────────────────────────────────────────────
#  mise 글로벌 런타임 설치
# ───────────────────────────────────────────────────────
setup_mise_runtimes() {
  local tools=(rust python uv java maven node kotlin)

  for tool in "${tools[@]}"; do
    if mise ls --installed "$tool" 2>/dev/null | grep -q "$tool"; then
      success "$tool 이미 설치됨"
      continue
    fi

    local version
    case "$tool" in
      node)   version="lts" ;;
      kotlin) version="$(mise ls-remote kotlin | grep -E '^[0-9.]+$' | sort -V | tail -1)" ;;
      *)      version="latest" ;;
    esac

    info "$tool 설치 중 ($version)..."
    mise use -g "$tool@$version"
    success "$tool 설치 완료"
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_mise
  setup_mise_runtimes
  echo ""
  warn ".zshrc에 아래 설정이 필요합니다"
  info "  eval \"\$(mise activate zsh)\""
  info "  → .zshrc에 해당 설정이 있는지 확인해주세요"
fi
