# Aliases for modern CLI tools
# These replace traditional Unix commands with improved alternatives

# Navigation
# Use zoxide (smarter cd) - only if installed
if command -v zoxide &> /dev/null; then
    alias cd='z'
fi

# File viewing
# bat - cat with syntax highlighting and git integration
if command -v bat &> /dev/null; then
    # cat: no paging, just print the file
    alias cat='bat --paging=never'
    # less: use bat as a pager (still paginate long files)
    alias less='bat --paging=always'
    # batcat: original bat with default behavior
    alias batcat='bat'
elif command -v batcat &> /dev/null; then
    # On Ubuntu/Debian, bat is installed as batcat
    alias bat='batcat'
    alias cat='batcat --paging=never'
    alias less='batcat --paging=always'
fi

# File listing
# eza - modern ls with colors, icons, and git integration
if command -v eza &> /dev/null; then
    # Use a function so icons always show, even with custom flags
    ls() {
        eza --icons --git "$@"
    }

    # Convenient aliases
    alias ll='eza -l --git --icons'
    alias la='eza -la --git --icons'
    alias lt='eza -lT --git --icons'  # tree view
    alias l='eza -lah --git --icons'

    # Common ls flag translations for eza
    alias lrt='eza -l --git --icons --sort=modified'  # ls -lrt equivalent
    alias lrta='eza -la --git --icons --sort=modified'  # ls -lrta equivalent
fi

# System monitoring
# btop - modern system monitor
if command -v btop &> /dev/null; then
    alias top='btop'
fi

# Editor
# Use neovim instead of vim
if command -v nvim &> /dev/null; then
    alias vim='nvim'
    alias vi='nvim'
    alias v='nvim'
fi

if command -v fzf &> /dev/null; then
    # fcd - fuzzy cd to selected directory
    fcd() {
        local dir
        dir=$(find ${1:-.} -path '*/\.*' -prune \
                        -o -type d -print 2> /dev/null | fzf +m) &&
        cd "$dir"
    }

    # fh - search in your command history and execute selected command
    fh() {
        eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
    }
fi

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Quick directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Safety aliases (ask before overwrite)
# Disable in non-interactive contexts like Claude Code
if [ -z "$NONINTERACTIVE" ]; then
    alias cp='cp -i'
    alias mv='mv -i'
    alias rm='rm -i'
fi

# Shortcuts
alias c='clear'
alias h='history'
alias j='jobs'

# Docker aliases (if you use Docker)
if command -v docker &> /dev/null; then
    alias d='docker'
    alias dc='docker compose'
    alias dps='docker ps'
    alias di='docker images'
    alias dex='docker exec -it'
fi

# Network
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias show='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
    alias hide='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
    alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
fi

# Reload zsh config
alias reload='source ~/.zshrc'
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'
alias aliasconfig='${EDITOR:-nvim} ~/.config/zsh/aliases.zsh'
