# zoxide - a better cd command
# Disable in non-interactive contexts like Claude Code (avoids __zoxide_z errors)
[ -z "$NONINTERACTIVE" ] && eval "$(zoxide init zsh)"
