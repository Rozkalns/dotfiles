# zoxide - a better cd command
# Must be initialized near the end of shell config (after aliases/keybindings,
# before ZLE plugins) to avoid zoxide doctor warnings.
# Disable in non-interactive contexts like Claude Code (avoids __zoxide_z errors)
if [ -z "$NONINTERACTIVE" ] && command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi
