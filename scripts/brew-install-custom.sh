#!/bin/bash

# Source utils.sh from the same directory as this script
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_DOTFILES_DIR="$(cd "$_SCRIPT_DIR/.." && pwd)"

# Add bin to PATH for utility scripts
export PATH="$_DOTFILES_DIR/bin:$PATH"

. "$_SCRIPT_DIR/utils.sh"

run_brew_bundle() {
    brewfile="$_SCRIPT_DIR/../homebrew/Brewfile"
    caskfile="$_SCRIPT_DIR/../homebrew/Caskfile"

    # Install from Brewfile (CLI tools)
    if [ -f "$brewfile" ]; then
        info "Installing CLI tools from Brewfile..."
        local check_output
        check_output=$(brew bundle check --file="$brewfile" 2>&1)

        if echo "$check_output" | grep -q "The Brewfile's dependencies are satisfied."; then
            success "Brewfile dependencies already satisfied."
        else
            brew bundle install --file="$brewfile" --verbose
        fi
    else
        error "Brewfile not found"
        return 1
    fi

    # Install from Caskfile (macOS apps) - only on macOS
    if is-macos && [ -f "$caskfile" ]; then
        printf "\n"
        info "Installing macOS applications from Caskfile..."
        local cask_check_output
        cask_check_output=$(brew bundle check --file="$caskfile" 2>&1)

        if echo "$cask_check_output" | grep -q "The Brewfile's dependencies are satisfied."; then
            success "Caskfile dependencies already satisfied."
        else
            brew bundle install --file="$caskfile" --verbose
        fi
    fi

    printf "\n"
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
        error "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi

    read -p "Install Brew bundle? [y/n] " install_bundle

    if [[ "$install_bundle" == "y" ]]; then
        run_brew_bundle
    fi
fi
