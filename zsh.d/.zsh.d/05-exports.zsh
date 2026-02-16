# Environment variables and exports

# Bat (better cat) configuration
export BAT_PAGER="less -RFX"
# -R: show colors
# -F: quit if one screen
# -X: don't clear screen on exit
# Note: Removed --mouse flag as it causes escape sequences to leak

# Neovim as MANPAGER
export MANPAGER='nvim +Man!'

# Pipenv
export PIPENV_VENV_IN_PROJECT=1
