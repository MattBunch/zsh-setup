# Portable Zsh Configuration
# Designed for Fedora, with forward compatibility for Ubuntu/Debian and Arch Linux

# ==============================================================================
# Environment & PATH Configuration
# ==============================================================================
# Native Zsh path deduplication
typeset -U path PATH

# Add standard user binary directories if they exist
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  $path
)
export PATH

# ==============================================================================
# Interactive Shell Options & Navigation
# ==============================================================================
# Use emacs keybindings by default (preserves standard cursor navigation)
bindkey -e

# ==============================================================================
# Completion
# ==============================================================================
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu selection on completion
zstyle ':completion:*' menu select

# ==============================================================================
# History Configuration
# ==============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# ==============================================================================
# Prefix History Search
# ==============================================================================
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Bind Up / Down arrow keys across various terminal modes
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# ==============================================================================
# Prompt
# ==============================================================================
PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f%# '

# ==============================================================================
# Plugins (Distro Package Path Detection)
# ==============================================================================
# zsh-autosuggestions
for _plugin_path in \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
do
  if [[ -r "$_plugin_path" ]]; then
    source "$_plugin_path"
    break
  fi
done

# zsh-syntax-highlighting (must be sourced after widgets/plugins)
for _plugin_path in \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
do
  if [[ -r "$_plugin_path" ]]; then
    source "$_plugin_path"
    break
  fi
done

unset _plugin_path

# ==============================================================================
# Machine-Local Overrides & Secrets (Ignored by Git)
# ==============================================================================
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
