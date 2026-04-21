---
name: oneq-control-tmux-pane
description: 다른 tmux pane의 출력을 수집·분석하고, 쉘 프롬프트 상태일 때 명령도 전송
disable-model-invocation: true
---

# tmux Pane 조작

현재 tmux 세션의 다른 pane에서 버퍼를 가져와 분석하고, 필요하면 명령을 전송해 상호작용하는 스킬.

## 사용 전제

- Claude가 tmux 안에서 실행 중이어야 함 (`$TMUX` 셋)
- 사용자가 대상 pane을 명시 (예: "pane 2", ".2")

## 작업 루프

매 단계마다 (1) 상태를 확인하고, (2) 상태에 맞는 액션(캡처 또는 전송)을 고르고, (3) 결과를 분석한 뒤 다음 단계를 정한다. 사용자 요청을 다 처리할 때까지 반복.

### 1. 상태 확인 (항상 먼저)

대상 pane 버퍼의 최근 30라인을 캡처해 현재 상태를 직접 읽고 판단한다. 프로세스 이름만으로는 모호하므로 실제 버퍼 내용을 분석해 결정.

```bash
TARGET=".2"
tmux capture-pane -t "$TARGET" -p -S -30
```

버퍼를 보고 파악할 것:
- 마지막 줄이 쉘 프롬프트(`%`, `$`, `#`, 또는 커스텀 PS1)로 끝남 → **명령 전송 가능**
- vim/less/nvim/REPL/pager/서버 로그·테일링 등 쉘이 아닌 상태 → **캡처만 가능, send-keys 금지**
- 직전 명령이 아직 진행 중(출력이 흐르고 프롬프트 없음) → 현재까지 출력은 분석 가능. 새 명령 필요하면 완료 대기 후 다시 상태 확인.
- 사용자가 타이핑 중인 미완성 입력 보임 → send-keys 금지, 사용자에게 확인.
- `cwd`, 가상환경, 활성 컨테이너 등 이후 명령/출력 해석에 영향 주는 컨텍스트 파악.

상태를 한 줄로 요약해 사용자에게 먼저 알리고 다음 액션으로 진행.

### 2a. 버퍼 캡처 & 분석

```bash
tmux capture-pane -t "$TARGET" -p -S -500   # 필요 시 -S 값 확대
```

- 실시간 흐름 추적이 필요하면 짧은 간격으로 여러 번 캡처해 증가분 비교.
- scrollback 한계를 넘어간 내용은 복원 불가 — 가능한 초기에 캡처.
- `grep`/`awk`/`sed` 로 관심 라인/구간만 추려 보고.

### 2b. 명령 전송 & 출력 수집

쉘 프롬프트 상태일 때만. 센티넬 마커로 경계를 감싸 전송하면 BEGIN~END 사이만 해당 명령의 출력이다.

```bash
NONCE="$(date +%s)_$$"
BEGIN="__TMUX_BEGIN_${NONCE}__"
END="__TMUX_END_${NONCE}__"
CMD='cd /mail/logs && grep -c ERROR *.log | head'

# 외부 "..." 로 NONCE 확장 허용, $? 는 대상 쉘에서 확장되도록 \$? 로 이스케이프
tmux send-keys -t "$TARGET" "printf '\n%s\n' '$BEGIN'; ${CMD}; printf '\n%s rc=%s\n' '$END' \"\$?\"" Enter
```

복잡한 이스케이프(따옴표·백틱·개행 포함)가 필요하면 `/tmp/` 에 스크립트를 쓰고 `bash /tmp/xxx.sh` 만 전송.

END 마커가 **줄 시작**에 나올 때까지 대기. zsh가 send-keys 내용을 입력 에코할 때 같은 줄 중간에도 마커 문자열이 찍히므로, `^` 앵커로 실제 출력만 인식한다. 타임아웃 포함:

```bash
DEADLINE=$(( $(date +%s) + 120 ))
until tmux capture-pane -t "$TARGET" -p -S -5000 | grep -q "^$END"; do
  [[ $(date +%s) -ge $DEADLINE ]] && { echo "timeout"; break; }
  sleep 1
done
```

BEGIN~END 구간과 rc 추출. 여기서도 에코된 입력 라인에 마커가 중간에 박혀 있으므로 `^` 앵커로 **줄 시작 매칭만** 인정한다.

```bash
BUF="$(tmux capture-pane -t "$TARGET" -p -S -5000)"

OUT="$(printf '%s\n' "$BUF" | awk -v b="^$BEGIN" -v e="^$END" '
  $0 ~ b {f=1; next}
  $0 ~ e {f=0}
  f
')"

RC="$(printf '%s\n' "$BUF" | awk -v e="^$END" '$0 ~ e { for(i=1;i<=NF;i++) if($i ~ /^rc=/){ sub(/^rc=/,"",$i); print $i; exit } }')"
```

출력이 scrollback을 넘기면 `-S` 값을 더 크게 하거나 명령을 파일로 리다이렉트해서 `cat` 으로 회수.

### 3. 다음 단계 결정

결과를 보고 더 캡처할지, 명령을 이어 보낼지, 보고하고 끝낼지 정한다. 상태가 바뀌었을 수 있으므로 액션 전에는 항상 1로 돌아가 상태 재확인.

## 안전 수칙

- **파괴적 명령** (`rm -rf`, `drop`, `git push --force` 등)은 반드시 사용자 확인 후 전송.
- **상태 잔류**: `cd`/환경변수/alias 는 pane에 남는다. 연속 명령이면 의도한 상태인지 매번 확인.
- **사용자 입력 간섭 금지**: 사용자가 타이핑 중인 pane에는 send-keys 금지.
- **인터랙티브 프로세스**: vim/less/psql 등에는 send-keys 금지. 출력 분석만 수행하거나, 조작이 필요하면 사용자에게 빠져나오도록 요청.
- **멱등성 없음**: 같은 명령도 상태에 따라 결과 달라짐. 필요하면 절대경로/명시적 컨텍스트 사용.

## 결과 보고 형식

```
## pane 상태
- pane: .2 (zsh @ /path/to/cwd, 또는 "nginx 로그 tail 중")

## 수행
- [캡처] 5000라인 / [전송] <명령 요약> rc=0

## 출력 (요약)
<핵심 라인만>

## 분석
<사용자 요청에 대한 답/발견점>
```

출력이 길면 원본 버퍼는 `/tmp/` 에 저장하고 경로만 보고에 포함한다.
