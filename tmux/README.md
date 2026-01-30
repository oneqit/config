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
| `t` | tmux 시작 (세션 있으면 attach, 없으면 new) |
| `tcode` | 2:1 분할 + nvim/claude 실행 (좌측 포커스) |
| `tcode vim htop` | 2:1 분할 + 커스텀 명령어 실행 |
| `tn` | 새 세션 (`-s <name>`) |
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
| `Prefix + 방향키` | 패널 크기 조절 |
