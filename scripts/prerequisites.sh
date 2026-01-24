#!/bin/bash

# Source utils.sh from the same directory as this script
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_DOTFILES_DIR="$(cd "$_SCRIPT_DIR/.." && pwd)"

# Add bin to PATH for utility scripts
export PATH="$_DOTFILES_DIR/bin:$PATH"

. "$_SCRIPT_DIR/utils.sh"

install_xcode() {
    info "Installing Apple's CLI tools (prerequisites for Git and Homebrew)..."
    if xcode-select -p >/dev/null; then
        warning "xcode is already installed"
    else
        xcode-select --install
        sudo xcodebuild -license accept
    fi
}

install_homebrew() {
    info "Installing Homebrew..."

    if is-executable brew; then
        warning "Homebrew already installed"
    else
        if is-macos; then
            # macOS
            export HOMEBREW_CASK_OPTS="--appdir=/Applications"
            sudo --validate
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            # Linux
            info "Installing build dependencies for Linux..."
            if is-executable apt-get; then
                sudo apt-get update
                sudo apt-get install -y build-essential procps curl file git
            elif is-executable dnf; then
                sudo dnf groupinstall -y 'Development Tools'
                sudo dnf install -y procps-ng curl file git
            fi

            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for Linux
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_xcode
    install_homebrew
fi