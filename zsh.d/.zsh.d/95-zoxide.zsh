# zoxide - a better cd command
# Must be initialized near the end of shell config (after aliases/keybindings,
# before ZLE plugins) to avoid zoxide doctor warnings.
# Skip in agent contexts like Claude Code: the precmd hook isn't last there,
# so zoxide prints "_ZO_DOCTOR" config warnings on every command (and
# __zoxide_z errors).
if [ -z "$CLAUDECODE" ] && [ -z "$AI_AGENT" ] && command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi
