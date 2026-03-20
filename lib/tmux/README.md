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

`init.sh` 혹은 `lib/tmux/setup.sh`를 실행하면 `.tmux.conf` 심볼릭 링크와 `.zshrc` 설정이 자동으로 적용된다.

## 쉘 함수 & Alias

| 명령어 | 설명 |
|---|---|
| `t` | tmux 새 세션 시작 (`-s <name>`) |
| `ta` | 세션 attach (`-t <name>`) |
| `tl` | 세션 목록 |
| `tc` | 세션 선택 |
| `tk` | 세션 종료 (`-t <name>`) |
| `tK` | tmux 서버 종료 |

### 개발 환경 분할 함수

tmux 밖에서는 새 세션 생성, tmux 안에서는 현재 창 분할. 인자로 커스텀 명령어 지정 가능.

| 명령어 | 설명 |
|---|---|
| `qlaude` | 2분할: nvim + claude |
| `qodex` | 2분할: nvim + codex |
| `qopilot` | 2분할: nvim + copilot |
| `qode` | 3분할: nvim + claude + copilot |

예: `qlaude vim htop` — nvim 대신 vim, claude 대신 htop 실행

### SSH 자동 TERM 변환

tmux 내에서 ssh 실행 시 TERM을 `xterm-256color`로 자동 변환 (원격 서버에 tmux terminfo가 없는 경우 대비)

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
| `C-v` | 사각형 선택 토글 |
| `y` / `ㅛ` | 복사 |
| `h/j/k/l` | 커서 이동 |
| `ㅗ/ㅓ/ㅏ/ㅣ` | 커서 이동 (한글 키) |
| `C-e` | 아래로 스크롤 |
| `C-y` | 위로 스크롤 |
| `q` / `ㅂ` | copy-mode 종료 |

## 입력기 상태 표시 (macOS 전용)

상태바 우측에 현재 입력기(한/EN)를 표시한다. 한글 입력 중에는 `[한]`과 함께 배경색이 변경되고, 영문 입력 중에는 `[EN]`이 기본 스타일로 표시된다.

- `tmux-im-status.swift` — macOS 입력 소스 변경을 감지하여 tmux 변수(`@im-status`)와 `status-style`을 업데이트하는 Swift 데몬
- `com.oneq.tmux-im-status.plist` — launchd로 데몬을 자동 실행하는 설정
- `setup_tmux_im_status` 함수가 컴파일, plist 배포, 서비스 등록을 처리

## 기타 설정

| 설정 | 설명 |
|---|---|
| `mouse on` | 마우스 지원 (스크롤, 패널 선택/크기 조절) |
| `set-clipboard on` | 클립보드 연동 |
| `focus-events on` | vim autoread용 포커스 이벤트 활성화 |
| `history-limit 10000` | 스크롤백 버퍼 크기 |
| `status-interval 1` | 상태바 1초마다 갱신 |
| 마우스 휠 스크롤 | 1줄 단위로 느리게 스크롤 |
| 패널 보더 표시 | 활성 패널 상단에 인덱스, 경로, 명령어 표시 |
