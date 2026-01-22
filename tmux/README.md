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

tmux 설정 파일을 심볼릭 링크로 연결합니다.

```bash
ln -sf ~/code/oneqit/config/tmux/.tmux.conf ~/.tmux.conf
```

## 주요 키 바인딩

| 키 | 설명 |
|---|---|
| `Ctrl+Space` | Prefix 키 |
| `Prefix + \|` | 수평 분할 |
| `Prefix + -` | 수직 분할 |
| `Prefix + h/j/k/l` | 패널 이동 (vi 스타일) |
| `Prefix + 방향키` | 패널 크기 조절 |
