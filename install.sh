#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/scripts/utils.sh
. $SCRIPT_DIR/scripts/prerequisites.sh
. $SCRIPT_DIR/scripts/brew-install-custom.sh
. $SCRIPT_DIR/scripts/themes.sh
. $SCRIPT_DIR/scripts/osx-defaults.sh
. $SCRIPT_DIR/scripts/symlinks.sh

info "Dotfiles installation initialized..."
read -p "Install apps? [y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "===================="
    info "Prerequisites"
    info "===================="

    # macOS-specific prerequisites
    if [[ "$OSTYPE" == "darwin"* ]]; then
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
fi

# macOS-specific system defaults
if [[ "$OSTYPE" == "darwin"* ]]; then
    printf "\n"
    info "===================="
    info "OSX System Defaults"
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
