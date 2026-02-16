# ZSH Plugins - Must be loaded at the END
# These plugins hook into the ZLE (Zsh Line Editor) and must be loaded after
# all other widgets and customizations are complete

# Configure autosuggestions BEFORE loading (to prevent being overridden)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_USE_ASYNC=true

# Activate autosuggestions
if [ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Activate syntax highlighting
# Configure which highlighters to use (exclude 'main' from suggestion region)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Note: Catppuccin theme for zsh-syntax-highlighting is disabled because it
# overrides autosuggestion colors, making them appear bright instead of dim.
# The default syntax highlighting colors work well without it.
#
# if [ -f ~/.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh ]; then
#     source ~/.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
# fi

# Now load the syntax highlighting plugin (MUST be last!)
if [ -f $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Configure syntax highlighting styles (AFTER loading plugin)
# Disable path underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
