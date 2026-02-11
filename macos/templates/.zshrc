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
  # zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source "$ZSH/oh-my-zsh.sh"

# ═══════════════════════════════════════════════════════
#  Starship
# ═══════════════════════════════════════════════════════
eval "$(starship init zsh)"

# ═══════════════════════════════════════════════════════
#  Extras
# ═══════════════════════════════════════════════════════

