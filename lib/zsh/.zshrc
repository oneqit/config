# ═══════════════════════════════════════════════════════
#  .zshrc
# ═══════════════════════════════════════════════════════
# ─── Common ───
export LANG=ko_KR.UTF-8

# ─── PATH ───
export PATH="$HOME/.local/bin:$PATH"

# ─── Platform-specific ───
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ─── Editor ───
if command -v nvim &>/dev/null; then
  export EDITOR=nvim
elif command -v vim &>/dev/null; then
  export EDITOR=vim
else
  export EDITOR=vi
fi

# ─── Config repo ───
if [[ -d ~/.config/oneqit/config ]]; then
  ONEQIT_CONFIG=~/.config/oneqit/config
elif [[ -d __ONEQIT_CONFIG__ ]]; then
  ONEQIT_CONFIG=__ONEQIT_CONFIG__
fi

# ═══════════════════════════════════════════════════════
#  Oh My Zsh
# ═══════════════════════════════════════════════════════
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-completions
)

if [[ -d "$ZSH" ]]; then
  source "$ZSH/oh-my-zsh.sh"

  # ─── zsh-syntax-highlighting 경로 밑줄 비활성화 ───
  typeset -A ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[path]='none'
fi

# ═══════════════════════════════════════════════════════
#  Starship
# ═══════════════════════════════════════════════════════
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ═══════════════════════════════════════════════════════
#  tmux
# ═══════════════════════════════════════════════════════
[[ -n "${ONEQIT_CONFIG:-}" && -f "$ONEQIT_CONFIG/lib/tmux/.zshrc.append" ]] && source "$ONEQIT_CONFIG/lib/tmux/.zshrc.append"

# ═══════════════════════════════════════════════════════
#  mise
# ═══════════════════════════════════════════════════════
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# ═══════════════════════════════════════════════════════
#  Git
# ═══════════════════════════════════════════════════════
gaagc() {
  git add -A || return 1
  git status
  echo -e "\033[0;34mGenerating commit message with Claude...\033[0m"
  git commit -e -m "$(claude -p '/oneq-create-commit-message-on-staged')"
}

# ═══════════════════════════════════════════════════════
#  Extras — 아래에 추가한 설정은 init/setup 재실행 시에도 보존
# ═══════════════════════════════════════════════════════

