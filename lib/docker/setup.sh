#!/usr/bin/env bash

_DOCKER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_DOCKER_DIR/../logging.sh"
source "$_DOCKER_DIR/../platform.sh"

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

  if [[ -d "/opt/homebrew/opt/docker-compose" ]] || brew list docker-compose &>/dev/null; then
    success "Docker Compose 이미 설치됨"
  else
    info "Docker Compose 설치 중..."
    brew install docker-compose
    success "Docker Compose 설치 완료"
  fi

  if [[ -d "/opt/homebrew/opt/docker-buildx" ]] || brew list docker-buildx &>/dev/null; then
    success "Docker Buildx 이미 설치됨"
  else
    info "Docker Buildx 설치 중..."
    brew install docker-buildx
    success "Docker Buildx 설치 완료"
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
#  Docker CLI 플러그인 설정 (config.json)
# ───────────────────────────────────────────────────────
setup_docker_cli_plugins() {
  local config_file="$HOME/.docker/config.json"
  local plugins_dir="/opt/homebrew/lib/docker/cli-plugins"

  mkdir -p "$HOME/.docker"

  if [[ -f "$config_file" ]]; then
    if jq -e ".cliPluginsExtraDirs // [] | index(\"$plugins_dir\")" "$config_file" &>/dev/null; then
      success "Docker CLI 플러그인 경로 이미 설정됨"
      return
    fi
    warn "config.json 이미 존재 → 백업"
    cp "$config_file" "${config_file}.backup.$(date +%Y%m%d%H%M%S)"
    info "config.json에 cliPluginsExtraDirs 추가 중..."
    local updated
    updated=$(jq --arg dir "$plugins_dir" '.cliPluginsExtraDirs = ((.cliPluginsExtraDirs // []) + [$dir] | unique)' "$config_file")
    printf '%s\n' "$updated" > "$config_file"
  else
    info "config.json 생성 중..."
    jq -n --arg dir "$plugins_dir" '{"cliPluginsExtraDirs": [$dir]}' > "$config_file"
  fi

  success "Docker CLI 플러그인 경로 설정 완료 → $plugins_dir"
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

# ───────────────────────────────────────────────────────
#  Docker Engine 설치 (Linux, Docker 공식 apt 저장소)
# ───────────────────────────────────────────────────────
install_docker_engine() {
  local packages=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
  # 공식 패키지와 충돌하는 배포판 제공 패키지
  local conflicts=(docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc)
  local sources="/etc/apt/sources.list.d/docker.sources"
  local distro codename

  distro="$(. /etc/os-release && echo "$ID")"
  codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
  [[ "$distro" == "ubuntu" || "$distro" == "debian" ]] || error "Docker 공식 apt 저장소는 Ubuntu/Debian만 지원합니다: $distro"

  for pkg_name in "${conflicts[@]}"; do
    if dpkg-query -W -f='${Status}' "$pkg_name" 2>/dev/null | grep -q 'ok installed'; then
      info "배포판 제공 패키지 $pkg_name 제거 중..."
      sudo apt-get remove -y "$pkg_name"
    fi
  done

  if [[ -f "$sources" ]]; then
    success "Docker apt 저장소 이미 등록됨"
  else
    info "Docker apt 저장소 등록 중..."
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL "https://download.docker.com/linux/$distro/gpg" -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    sudo tee "$sources" >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/$distro
Suites: $codename
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    sudo apt-get update
    success "Docker apt 저장소 등록 완료"
  fi

  for pkg_name in "${packages[@]}"; do
    if dpkg -s "$pkg_name" &>/dev/null; then
      success "$pkg_name 이미 설치됨"
    else
      info "$pkg_name 설치 중..."
      sudo apt-get install -y "$pkg_name"
      success "$pkg_name 설치 완료"
    fi
  done

  if id -nG "$USER" | grep -qw docker; then
    success "docker 그룹 이미 설정됨"
  else
    info "$USER 를 docker 그룹에 추가 중..."
    sudo usermod -aG docker "$USER"
    success "docker 그룹 추가 완료 (재로그인 후 sudo 없이 docker 사용 가능)"
  fi
}

# ───────────────────────────────────────────────────────
#  단독 실행
# ───────────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if is_linux; then
    install_docker_engine
  else
    install_docker
    setup_docker_cli_plugins
    install_colima
  fi
fi
