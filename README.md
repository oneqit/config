# config

초기 환경 세팅 스크립트

## 개요

새 OS에서 `./init.sh` 한 번 실행으로 개발 환경 전체를 세팅하기 위한 프로젝트.

### 지원 플랫폼

| 플랫폼 | 지원 수준 | 현재 상태 |
|---|---|---|
| macOS | 필수 | 지원 |
| Linux | 필수 | apt 기반 Ubuntu/Debian 지원 (GUI 앱 제외) |
| Termux (Android) | 일부 지원 | 셸·터미널 도구, AI CLI만 세팅 (GUI 앱, mise, Docker 제외) |

## 설치

### HTTPS
```bash
git clone https://github.com/oneqit/config.git ~/.config/oneqit/config
```

### SSH
```bash
git clone git@github.com:oneqit/config.git ~/.config/oneqit/config
```

## 사용법

전체 세팅:

```bash
cd ~/.config/oneqit/config
./init.sh
```

개별 도구만 세팅 (`curl`, `git` 필요):

```bash
./lib/zsh/setup.sh       # Oh My Zsh + .zshrc
./lib/starship/setup.sh  # Starship 프롬프트
./lib/tmux/setup.sh      # tmux 설정
./lib/ghostty/setup.sh   # Ghostty 터미널 (macOS)
./lib/docker/setup.sh    # Docker 설치 (macOS: CLI + Colima / Linux: Docker Engine)
./lib/karabiner/setup.sh # Karabiner-Elements 키매핑 (macOS)
./lib/linearmouse/setup.sh # LinearMouse 마우스 스크롤 반전 (macOS)
./lib/mise/setup.sh      # mise 런타임 매니저
```

> **참고:** Karabiner-Elements 설치 시 시스템 패스워드를 요구할 수 있습니다.

## 구조

```
init.sh              # 플랫폼 판별 → 디스패치
lib/
├── logging.sh       # 공유 로깅 함수
├── deploy.sh        # 설정 파일 배포 (백업 + 복사)
├── platform.sh      # 플랫폼 판별 함수
├── ai/
│   ├── claude-code/ # Claude Code 셋업
│   └── codex/       # Codex CLI 셋업
├── docker/          # Docker 설치 셋업
├── ghostty/         # Ghostty 설정 + 셋업
├── karabiner/       # Karabiner-Elements 키매핑 설정
├── linearmouse/     # LinearMouse 마우스 스크롤 반전 설정
├── mise/            # mise 런타임 매니저 셋업
├── starship/        # Starship 설정 + 셋업
├── tmux/            # tmux 설정 + 셋업
└── zsh/             # Oh My Zsh + .zshrc 셋업
macos/               # macOS 전용 (Homebrew, 폰트, 키보드 등)
linux/               # Linux 전용 (apt 패키지, 기본 셸 변경 등)
termux/              # Termux 전용 (pkg, 저장소 권한, 셸 변경 등)
```

## 도구별 문서

- [tmux 설정](lib/tmux/README.md)
