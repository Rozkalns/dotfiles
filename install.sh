#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add bin to PATH for utility scripts
export PATH="$SCRIPT_DIR/bin:$PATH"

. $SCRIPT_DIR/scripts/utils.sh
. $SCRIPT_DIR/scripts/prerequisites.sh
. $SCRIPT_DIR/scripts/brew-install-custom.sh
. $SCRIPT_DIR/scripts/themes.sh
. $SCRIPT_DIR/scripts/osx-defaults.sh
. $SCRIPT_DIR/scripts/symlinks.sh
. $SCRIPT_DIR/macos/dock.sh

info "Dotfiles installation initialized..."
read -p "Install apps? [y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "===================="
    info "Prerequisites"
    info "===================="

    # macOS-specific prerequisites
    if is-macos; then
        install_xcode
    fi

    install_homebrew

    printf "\n"
    info "===================="
    info "Apps"
    info "===================="

    run_brew_bundle

    printf "\n"
    info "===================="
    info "Themes"
    info "===================="

    install_catppuccin_themes

    # macOS-specific setup that requires installed apps
    if is-macos; then
        printf "\n"
        info "===================="
        info "Dock Setup"
        info "===================="

        if is-executable dockutil; then
            read -p "Configure Dock with preferred apps? [y/n] " configure_dock
            if [[ "$configure_dock" == "y" ]]; then
                setup_dock
            fi
        else
            warning "dockutil not installed - skipping Dock setup"
            info "Install with: brew install dockutil"
        fi

        printf "\n"
        info "===================="
        info "Default Applications"
        info "===================="

        if is-executable duti; then
            read -p "Set default applications (PHPStorm for code files)? [y/n] " set_defaults
            if [[ "$set_defaults" == "y" ]]; then
                info "Setting default applications..."
                duti "$SCRIPT_DIR/macos/duti"
                success "Default applications configured!"
            fi
        else
            warning "duti not installed - skipping default application setup"
            info "Install with: brew install duti"
        fi
    fi
fi

# macOS system defaults (can run even without installing apps)
if is-macos; then
    printf "\n"
    info "===================="
    info "macOS System Defaults"
    info "===================="

    register_keyboard_shortcuts
    apply_osx_system_defaults
fi

printf "\n"
info "===================="
info "Terminal"
info "===================="

info "Adding .hushlogin file to suppress 'last login' message in terminal..."
touch ~/.hushlogin

printf "\n"
info "===================="
info "Symbolic Links"
info "===================="

chmod +x $SCRIPT_DIR/scripts/symlinks.sh
if [[ "$overwrite_dotfiles" == "y" ]]; then
    warning "Deleting existing dotfiles..."
    $SCRIPT_DIR/scripts/symlinks.sh --delete --include-files
fi
$SCRIPT_DIR/scripts/symlinks.sh --create

printf "\n"
success "Dotfiles set up successfully."
printf "\n"
info "To activate your new shell configuration, run:"
info "    source ~/.zshrc"
info "Or open a new terminal window/tab."
printf "\n"
read -p "Reload shell now? [y/n] " reload_shell
if [[ "$reload_shell" == "y" ]]; then
    info "Reloading shell..."
    exec $SHELL
fi
