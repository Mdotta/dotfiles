# Keybinds for your fzf helpers (zsh)
# ZLE only exists in interactive shells.

[[ -o interactive ]] || return

# Ctrl+O => cproj
_cproj_widget() { cproj }
zle -N _cproj_widget
bindkey '^O' _cproj_widget

# Ctrl+P => cfile
_cfile_widget() { cfile }
zle -N _cfile_widget
bindkey '^P' _cfile_widget

# Ctrl+F => cprojfile
_cprojfile_widget() { cprojfile }
zle -N _cprojfile_widget
bindkey '^F' _cprojfile_widget