# ═══════════════════════════════════════════════════════
#  .zshrc
# ═══════════════════════════════════════════════════════

# ─── Homebrew PATH (Apple Silicon) ───
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ═══════════════════════════════════════════════════════
#  Oh My Zsh
# ═══════════════════════════════════════════════════════
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  # zsh-autosuggestions  # 제안 텍스트가 사고의 흐름을 방해하여 비활성화
  zsh-syntax-highlighting
  zsh-completions
)

source "$ZSH/oh-my-zsh.sh"

# ─── zsh-syntax-highlighting 경로 밑줄 비활성화 ───
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='none'

# ═══════════════════════════════════════════════════════
#  Starship
# ═══════════════════════════════════════════════════════
eval "$(starship init zsh)"

# ═══════════════════════════════════════════════════════
#  Extras
# ═══════════════════════════════════════════════════════

