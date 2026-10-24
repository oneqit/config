#!/usr/bin/env bash

_MISE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_MISE_DIR/../logging.sh"
source "$_MISE_DIR/../platform.sh"

# ───────────────────────────────────────────────────────
#  mise 설치
# ───────────────────────────────────────────────────────
install_mise() {
  if command -v mise &>/dev/null; then
    success "mise 이미 설치됨"
  else
    info "mise 설치 중..."
    if is_macos; then
      brew install mise
    else
      curl -fsSL https://mise.run | sh
      export PATH="$HOME/.local/bin:$PATH"  # 이어지는 mise 명령용 (~/.local/bin에 설치됨)
    fi
    success "mise 설치 완료"
  fi
}

# ───────────────────────────────────────────────────────
#  mise 글로벌 런타임 설치
# ───────────────────────────────────────────────────────
setup_mise_runtimes() {
  local tools=(rust uv java maven node kotlin go)

  for tool in "${tools[@]}"; do
    if mise ls --installed "$tool" 2>/dev/null | grep -q "$tool"; then
      success "$tool 이미 설치됨"
      continue
    fi

    local version
    case "$tool" in
      java)   version="temurin-21" ;;
      node)   version="lts" ;;
      kotlin) version="$(mise ls-remote kotlin | grep -E '^[0-9.]+$' | sort -V | tail -1)" ;;
      *)      version="latest" ;;
    esac

    info "$tool 설치 중 ($version)..."
    mise use -g "$tool@$version"
    success "$tool 설치 완료"
  done
}

# ───────────────────────────────────────────────────────
#  mise 글로벌 설정
# ───────────────────────────────────────────────────────
setup_mise_settings() {
  local tools=(java node)
  local current
  current="$(mise settings get idiomatic_version_file_enable_tools 2>/dev/null)"

  for tool in "${tools[@]}"; do
    if [[ "$current" == *"\"$tool\""* ]]; then
      success "idiomatic_version_file: $tool 이미 설정됨"
    else
      info "idiomatic_version_file: $tool 추가 중..."
      mise settings add idiomatic_version_file_enable_tools "$tool"
      success "idiomatic_version_file: $tool 추가 완료"
    fi
  done

  # HTTP 요청 실패 시 재시도 횟수 (기본값 3 → 1)
  if [[ "$(mise settings get http_retries 2>/dev/null)" == "1" ]]; then
    success "http_retries: 이미 설정됨 (1)"
  else
    info "http_retries: 1 설정 중..."
    mise settings set http_retries 1
    success "http_retries: 1 설정 완료"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_mise
  setup_mise_runtimes
  setup_mise_settings
  echo ""
  warn ".zshrc에 아래 설정이 필요합니다"
  info "  eval \"\$(mise activate zsh)\""
  info "  → .zshrc에 해당 설정이 있는지 확인해주세요"
fi
