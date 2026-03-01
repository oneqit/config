# Termux 트러블슈팅

## Claude Code 커스텀 커맨드가 인식되지 않는 경우

Claude Code는 커맨드 파일(`.claude/commands/*.md`)을 검색할 때 내장 ripgrep 바이너리를 사용한다.
패키지에 `arm64-android`용 바이너리가 포함되어 있지 않아 Termux에서는 커맨드 검색이 실패한다.

시스템에 설치된 `rg`를 Claude Code가 찾는 경로에 심링크하면 해결된다.

```bash
mkdir -p "$(npm root -g)/@anthropic-ai/claude-code/vendor/ripgrep/arm64-android"
ln -sf "$(which rg)" "$(npm root -g)/@anthropic-ai/claude-code/vendor/ripgrep/arm64-android/rg"
```

Claude Code를 재설치하거나 업데이트하면 심링크가 사라지므로 다시 실행해야 한다.
