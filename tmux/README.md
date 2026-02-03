# tmux 설정

## tmux 설치

### macOS

```bash
brew install tmux
```

### Ubuntu/Debian

```bash
sudo apt install tmux
```

### Termux (Android)

```bash
pkg install tmux
```

## 설정 적용

```bash
ln -sf $PWD/.tmux.conf ~/.tmux.conf
echo "source $PWD/.zshrc.append" >> ~/.zshrc
exec $SHELL
```

## 쉘 함수 & Alias

| 명령어 | 설명 |
|---|---|
| `t` | tmux 새 세션 시작 (`-s <name>`) |
| `qode` | 2:1 분할 + nvim/claude 실행 (좌측 포커스). tmux 밖에서는 새 세션 생성, tmux 안에서는 현재 창 분할 |
| `qode vim htop` | 2:1 분할 + 커스텀 명령어 실행 |
| `ta` | 세션 attach (`-t <name>`) |
| `tl` | 세션 목록 |
| `tc` | 세션 선택 |
| `tk` | 세션 종료 (`-t <name>`) |
| `tK` | tmux 서버 종료 |

## 주요 키 바인딩

| 키 | 설명 |
|---|---|
| `Ctrl+a` | Prefix 키 |
| `Prefix + \|` | 수평 분할 |
| `Prefix + -` | 수직 분할 |
| `Prefix + h/j/k/l` | 패널 이동 (vi 스타일) |
| `Prefix + ㅗ/ㅓ/ㅏ/ㅣ` | 패널 이동 (한글 키) |
| `Prefix + 방향키` | 패널 크기 조절 |

### copy-mode-vi 키 바인딩

| 키 | 설명 |
|---|---|
| `v` / `ㅍ` | 선택 시작 |
| `y` / `ㅛ` | 복사 |
| `h/j/k/l` | 커서 이동 |
| `ㅗ/ㅓ/ㅏ/ㅣ` | 커서 이동 (한글 키) |
| `C-e` | 아래로 스크롤 |
| `C-y` | 위로 스크롤 |
| `q` / `ㅂ` | copy-mode 종료 |

## 기타 설정

| 설정 | 설명 |
|---|---|
| `mouse on` | 마우스 지원 (스크롤, 패널 선택/크기 조절) |
| `set-clipboard on` | 클립보드 연동 |
| `focus-events on` | vim autoread용 포커스 이벤트 활성화 |
