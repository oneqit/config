#!/usr/bin/env bash

_DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_DOCKER_DIR/../logging.sh"

# ───────────────────────────────────────────────────────
#  Docker CLI 설치
# ───────────────────────────────────────────────────────
install_docker() {
  if command -v docker &>/dev/null; then
    success "Docker CLI 이미 설치됨"
  else
    info "Docker CLI 설치 중..."
    brew install docker
    success "Docker CLI 설치 완료"
  fi

  if brew list docker-compose &>/dev/null; then
    success "Docker Compose 이미 설치됨"
  else
    info "Docker Compose 설치 중..."
    brew install docker-compose
    success "Docker Compose 설치 완료"
  fi

  if command -v docker-credential-osxkeychain &>/dev/null; then
    success "Docker Credential Helper 이미 설치됨"
  else
    info "Docker Credential Helper 설치 중..."
    brew install docker-credential-helper
    success "Docker Credential Helper 설치 완료"
  fi
}

# ───────────────────────────────────────────────────────
#  Docker Compose 플러그인 심볼릭 링크
# ───────────────────────────────────────────────────────
setup_docker_compose_plugin() {
  local plugins_dir="$HOME/.docker/cli-plugins"
  local link_path="$plugins_dir/docker-compose"
  local target="/opt/homebrew/opt/docker-compose/bin/docker-compose"

  mkdir -p "$plugins_dir"

  if [[ -L "$link_path" ]] && [[ "$(readlink "$link_path")" == "$target" ]]; then
    success "Docker Compose 플러그인 링크 이미 설정됨"
    return
  fi

  if [[ -e "$link_path" ]]; then
    info "기존 docker-compose 플러그인 제거 중..."
    rm -f "$link_path"
  fi

  info "Docker Compose 플러그인 링크 생성 중..."
  ln -s "$target" "$link_path"
  success "Docker Compose 플러그인 링크 완료 → $link_path"
}

# ───────────────────────────────────────────────────────
#  Colima 설치
# ───────────────────────────────────────────────────────
install_colima() {
  if command -v colima &>/dev/null; then
    success "Colima 이미 설치됨"
  else
    info "Colima 설치 중..."
    brew install colima
    success "Colima 설치 완료"
  fi
}
