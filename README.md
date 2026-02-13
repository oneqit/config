# config

개발 환경 초기 세팅 스크립트

## 설치

```bash
git clone <repo-url> ~/.config/oneqit/config
```

## 사용법

전체 세팅:

```bash
cd ~/.config/oneqit/config
./init.sh
```

개별 도구만 세팅:

```bash
./lib/zsh/setup.sh       # Oh My Zsh + .zshrc
./lib/starship/setup.sh  # Starship 프롬프트
./lib/tmux/setup.sh      # tmux 설정
./lib/ghostty/setup.sh   # Ghostty 터미널 (macOS)
```

## 구조

```
init.sh              # 플랫폼 판별 → 디스패치
lib/
├── logging.sh       # 공유 로깅 함수
├── platform.sh      # 플랫폼 판별 함수
├── ghostty/         # Ghostty 설정 + 셋업
├── starship/        # Starship 설정 + 셋업
├── tmux/            # tmux 설정 + 셋업
└── zsh/             # Oh My Zsh + .zshrc 셋업
macos/               # macOS 전용 (Homebrew, 폰트, 키보드 등)
termux/              # Termux 전용 (pkg, 저장소 권한, 셸 변경 등)
```

## 도구별 문서

- [tmux 설정](lib/tmux/README.md)
