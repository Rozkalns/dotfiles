#!/bin/bash

# Source utils.sh from the same directory as this script
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_SCRIPT_DIR/utils.sh"

run_brew_bundle() {
    brewfile="$_SCRIPT_DIR/../homebrew/Brewfile"
    if [ -f $brewfile ]; then
        # Run `brew bundle check`
        local check_output
        check_output=$(brew bundle check --file="$brewfile" 2>&1)

        # Check if "The Brewfile's dependencies are satisfied." is contained in the output
        if echo "$check_output" | grep -q "The Brewfile's dependencies are satisfied."; then
            warning "The Brewfile's dependencies are already satisfied."
        else
            info "Satisfying missing dependencies with 'brew bundle install'..."
            printf "\n"

            # On Linux, skip casks (GUI apps don't work)
            if [[ "$OSTYPE" != "darwin"* ]]; then
                warning "Running on Linux - skipping casks (GUI apps)"
                brew bundle install --file="$brewfile" --verbose --no-upgrade 2>&1 | grep -v "Skipping cask"
            else
                brew bundle install --file="$brewfile" --verbose
            fi

            printf "\n"
        fi
    else
        error "Brewfile not found"
        return 1
    fi
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
