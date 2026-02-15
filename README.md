# config

초기 환경 세팅 스크립트

## 설치

### HTTPS
```bash
git clone https://github.com/oneqit/config.git ~/.config/oneqit/config
```

### SSH
1. 키 생성
    ```bash
    ssh-keygen -t ed25519 -C "<name>@<device-name>"
    ```

2. GitHub 설정에 공개키 등록 (`Settings > SSH and GPG keys > New SSH key`)
    1. macOS
        ```bash
        cat ~/.ssh/id_ed25519.pub | pbcopy
        ```
    2. Linux
        ```bash
        cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
        ```

3. clone
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
├── ghostty/         # Ghostty 설정 + 셋업
├── starship/        # Starship 설정 + 셋업
├── tmux/            # tmux 설정 + 셋업
└── zsh/             # Oh My Zsh + .zshrc 셋업
macos/               # macOS 전용 (Homebrew, 폰트, 키보드 등)
termux/              # Termux 전용 (pkg, 저장소 권한, 셸 변경 등)
```

## 도구별 문서

- [tmux 설정](lib/tmux/README.md)
