# Portable Zsh Configuration
# Designed for Fedora, with forward compatibility for Ubuntu/Debian and Arch Linux

# ==============================================================================
# Environment & PATH Configuration
# ==============================================================================
# Native Zsh path deduplication
typeset -U path PATH

# Add standard user binary directories if they exist
for _user_bin_dir in \
  "$HOME/.local/bin" \
  "$HOME/bin" \
  "$HOME/.cargo/bin"
do
  if [[ -d "$_user_bin_dir" ]]; then
    path=("$_user_bin_dir" $path)
  fi
done

unset _user_bin_dir
export PATH

# ==============================================================================
# Interactive Shell Options & Navigation
# ==============================================================================
# Use Emacs keybindings by default
bindkey -e

# Normal Left / Right arrows
bindkey '^[[D' backward-char
bindkey '^[[C' forward-char
bindkey '^[OD' backward-char
bindkey '^[OC' forward-char

# Ctrl + Left / Right: move one word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Alt + Left / Right: move one word
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word

# Traditional Emacs/Zsh word movement
bindkey '^[b' backward-word
bindkey '^[f' forward-word

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

unset _plugin_path

# ==============================================================================
# Machine-Local Overrides & Secrets (Ignored by Git)
# ==============================================================================
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ==============================================================================
# Terminal Tab / Window Titles
# ==============================================================================
autoload -Uz add-zsh-hook

_set_terminal_title_precmd() {
  print -Pn '\e]0;%n@%m:%~\a'
}

_set_terminal_title_preexec() {
  local cmd="${1%% *}"
  print -Pn "\e]0;%n@%m:%~ — ${cmd}\a"
}

add-zsh-hook precmd _set_terminal_title_precmd
add-zsh-hook preexec _set_terminal_title_preexec

# ==============================================================================
# Syntax Highlighting (Must be loaded last)
# ==============================================================================
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
