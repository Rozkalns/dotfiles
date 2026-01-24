#!/bin/bash

# Get the absolute path of the directory where the script is located
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_DOTFILES_DIR="$(cd "$_SCRIPT_DIR/.." && pwd)"

# Add bin to PATH for utility scripts
export PATH="$_DOTFILES_DIR/bin:$PATH"

. "$_SCRIPT_DIR/utils.sh"

install_catppuccin_themes() {
    info "Installing Catppuccin themes..."

    # Catppuccin for zsh-syntax-highlighting
    info "Downloading Catppuccin Mocha for zsh-syntax-highlighting..."
    mkdir -p "$HOME/.config/zsh"
    curl -fsSL https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh \
        -o "$HOME/.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh"

    if [ $? -eq 0 ]; then
        success "Zsh syntax highlighting theme installed"
    else
        error "Failed to download zsh syntax highlighting theme"
    fi

    # Catppuccin for btop
    info "Downloading Catppuccin Mocha for btop..."
    mkdir -p "$HOME/.config/btop/themes"
    curl -fsSL https://raw.githubusercontent.com/catppuccin/btop/main/themes/catppuccin_mocha.theme \
        -o "$HOME/.config/btop/themes/catppuccin_mocha.theme"

    if [ $? -eq 0 ]; then
        success "Btop theme installed"

        # Set the theme in btop config
        mkdir -p "$HOME/.config/btop"
        if [ -f "$HOME/.config/btop/btop.conf" ]; then
            # Update existing config
            if grep -q "^color_theme" "$HOME/.config/btop/btop.conf"; then
                sed -i '' 's/^color_theme.*/color_theme = "catppuccin_mocha"/' "$HOME/.config/btop/btop.conf"
            else
                echo 'color_theme = "catppuccin_mocha"' >> "$HOME/.config/btop/btop.conf"
            fi
        else
            # Create new config
            echo 'color_theme = "catppuccin_mocha"' > "$HOME/.config/btop/btop.conf"
        fi
        success "Btop configured to use Catppuccin Mocha theme"
    else
        error "Failed to download btop theme"
    fi
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_catppuccin_themes
fi
