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

`init.sh` 혹은 `lib/tmux/setup.sh`를 실행하면 `.tmux.conf`가 `~/.tmux.conf`로 복사된다 (기존 파일과 다르면 백업 후 덮어쓰기). macOS에서는 입력기 상태 표시 데몬도 함께 설치된다.

쉘 함수는 `lib/zsh/.zshrc`가 `lib/tmux/.zshrc.append`를 source하는 방식으로 적용된다. `lib/tmux/setup.sh`만 단독 실행한 경우에는 `.zshrc`에 해당 source 구문이 있는지 직접 확인해야 한다.

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
| `qode` | 3분할: nvim + claude + codex |

예: `qlaude vim htop` — nvim 대신 vim, claude 대신 htop 실행

실행 후 포커스는 오른쪽 상단 패널(claude/codex)에 위치

창 이름은 실행한 디렉터리명으로 설정 (예: `~/code`에서 실행 시 `code`)

### 원격 세션 함수

`~/.ssh/config`의 `Host remote`로 원격 호스트에 접속해 이름이 일치하는 tmux 윈도우로 이동한다 (원격 호스트에서 실행하면 ssh 없이 바로 동작). 윈도우가 없으면 기존 세션에 명령을 실행하는 윈도우를 새로 만들고, 세션도 없으면 세션을 새로 만든다. attach로 들어간 경우 명령이 끝나면 클라이언트가 detach된다. 원격에도 이 설정(zsh, `rt` 함수)이 적용되어 있어야 한다.

| 명령어 | 설명 |
|---|---|
| `rt <name> '<cmd>'` | 원격의 `<name>` 윈도우로 이동 (없으면 cmd로 생성). cmd에는 따옴표 금지, `~`는 원격에서 펼쳐지도록 작은따옴표로 전달 |
| `qseq [claude\|codex]` | 원격 `seqretary-<agent>` 윈도우: 왼쪽 셸 + 오른쪽 에이전트(마지막 세션 이어서). 기본값 `claude` |
| `qmon` | 원격 `snowball-monitor` 윈도우에서 모니터 봇 실행 |

예: `rt dev 'cd ~/code/project && claude'` — 원격의 `dev` 윈도우로 이동하고, 없으면 `~/code/project`에서 claude를 실행하는 윈도우 생성

`~/.ssh/config` 예 (기기마다 수동 설정):

```sshconfig
Host remote
    HostName <원격 호스트 주소>
    Port <sshd 포트>
    User <계정>
```

### SSH 자동 TERM 변환

tmux 내에서 ssh 실행 시 TERM을 `xterm-256color`로 자동 변환 (원격 서버에 tmux terminfo가 없는 경우 대비)

## 주요 키 바인딩

| 키 | 설명 |
|---|---|
| `Ctrl+a` 또는 `F1` | Prefix 키 (자동 영문 전환) |
| `Prefix + \|` 또는 `%` | 수평 분할 |
| `Prefix + -` 또는 `"` | 수직 분할 |
| `Prefix + _` | 수직 3분할 |
| `Prefix + F` | 현재 패널의 Claude Code / Codex 세션을 fork해 아래 패널에서 resume (`tmux-agent-fork`, Codex는 같은 디렉터리의 최근 세션) |
| `Prefix + h/j/k/l` | 패널 이동 (vi 스타일) |
| `Prefix + 방향키` | 패널 크기 조절 |
| `Prefix + <` / `>` | 윈도우를 왼쪽/오른쪽으로 이동 (순서 교체) |
| `Prefix + Ctrl+a` | 프로그램에 Ctrl+a 전송 |
| `Prefix + F1` | 프로그램에 F1 전송 (중첩 tmux에서 F1 두 번 → 안쪽 prefix) |
| `Prefix + y` | 현재 디렉터리 클립보드 복사 |

> **한글 입력 호환:** Prefix(`Ctrl+a` / `F1`) 입력 시 macOS 입력기가 자동으로 영문 전환되므로, 한글 입력 상태에서도 모든 키 바인딩이 정상 동작한다. 한글 중복 바인딩(ㅗ/ㅓ/ㅏ/ㅣ 등)은 불필요하여 제거됨.

### copy-mode-vi 키 바인딩

| 키 | 설명 |
|---|---|
| `v` | 선택 시작 |
| `C-v` | 사각형 선택 토글 |
| `y` | 복사 |
| `h/j/k/l` | 커서 이동 |
| `C-e` | 아래로 스크롤 |
| `C-y` | 위로 스크롤 |
| `ESC` | 선택 해제 (더블: copy-mode 종료) |

### 마우스 동작

| 동작 | 설명 |
|---|---|
| 더블클릭 | 공백 기준 단어 선택 (경로, 브랜치명, URL 전체 선택) 후 복사하고 copy-mode 종료 |
| 드래그 | 놓는 순간 복사하고 copy-mode 종료 (tmux 기본 동작) |

## 입력기 상태 표시 및 자동 전환 (macOS 전용)

상태바 우측에 현재 입력기(한/EN)를 표시한다. 한글 입력 중에는 `[한]`과 함께 배경색이 변경되고, 영문 입력 중에는 `[EN]`이 기본 스타일로 표시된다.

- `tmux-im-status.swift` — 두 가지 모드로 동작하는 Swift 바이너리
  - **데몬 모드** (인자 없이 실행): macOS 입력 소스 변경을 감지하여 tmux 변수(`@im-status`)와 `status-style`을 업데이트
  - **`switch-english` 모드**: 입력기를 영문(ABC)으로 전환 후 즉시 종료. Prefix 키 입력 시 tmux가 `run-shell -b`로 호출하여 후속 키 입력이 영문으로 동작하도록 함
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
