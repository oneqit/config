---
name: oneq-control-tmux-pane
description: 다른 tmux pane 에 명령을 보내고 그 명령의 출력과 종료 코드만 정확히 회수한다
disable-model-invocation: true
---

# tmux pane 에 명령 보내기

pane 을 읽기만 할 때는 `tmux capture-pane -t <pane> -p -S -<줄수>` 로 충분하다. 이 스킬은 **명령을 보낼 때** 쓴다.

전제: Claude 가 tmux 안에서 실행 중(`$TMUX`)이고, 사용자가 대상 pane 을 지정했다(예: `.2`, `1.1`).

## 보내기 전에 — 매번

`tmux capture-pane -t "$TARGET" -p -S -30` 으로 마지막 줄을 본다. 보내도 되는 건 **쉘 프롬프트로 끝날 때만**이다.

- vim · less · psql · REPL · 로그 tail 등 쉘이 아님 → 보내지 않는다. 필요하면 사용자에게 빠져나와 달라고 한다
- 사용자가 치던 입력이 프롬프트에 남아 있음 → 보내지 않고 묻는다
- 이전 명령이 아직 출력 중 → 끝날 때까지 기다린 뒤 다시 본다
- `cd` · 환경변수 · 가상환경은 pane 에 남는다 — 지금 cwd · 컨텍스트가 의도한 것인지 본다

## 보내기 — 경계 표시로 감싼다

```bash
TARGET=".2"
NONCE="$(date +%s)_$$"
BEGIN="__TMUX_BEGIN_${NONCE}__"
END="__TMUX_END_${NONCE}__"
CMD='grep -c ERROR /var/log/app/*.log'

# $? 는 대상 쉘에서 확장되게 \$? 로
tmux send-keys -t "$TARGET" "printf '\n%s\n' '$BEGIN'; ${CMD}; printf '\n%s rc=%s\n' '$END' \"\$?\"" Enter
```

따옴표 · 백틱 · 여러 줄이 섞이면 스크립트 파일로 써서 `bash <파일>` 만 보낸다.

## 기다리고 회수하기

zsh 는 보낸 입력을 화면에 그대로 다시 찍으므로, 그 줄 가운데에도 마커 문자열이 보인다. **줄 시작(`^`)에 있는 마커만** 진짜 출력으로 본다.

```bash
DEADLINE=$(( $(date +%s) + 120 ))
until tmux capture-pane -t "$TARGET" -p -S -5000 | grep -q "^$END"; do
  [[ $(date +%s) -ge $DEADLINE ]] && { echo timeout; break; }
  sleep 1
done

BUF="$(tmux capture-pane -t "$TARGET" -p -S -5000)"
OUT="$(printf '%s\n' "$BUF" | awk -v b="^$BEGIN" -v e="^$END" '$0 ~ b {f=1; next} $0 ~ e {f=0} f')"
RC="$(printf '%s\n' "$BUF" | awk -v e="^$END" '$0 ~ e { for (i=1;i<=NF;i++) if ($i ~ /^rc=/) { sub(/^rc=/,"",$i); print $i; exit } }')"
```

출력이 scrollback 을 넘길 만큼 길면 명령 출력을 파일로 돌려 받고 그 파일을 읽는다.

## 안전 수칙

- 파괴적 명령(`rm -rf` · `drop` · `git push --force` 등)은 사용자 확인 후에만 보낸다
- 다음 명령을 보내기 전에는 다시 "보내기 전에" 로 돌아간다 — 그 사이 상태가 바뀌었을 수 있다
- 보고에는 보낸 명령 · rc · 출력의 핵심 줄만 적는다
