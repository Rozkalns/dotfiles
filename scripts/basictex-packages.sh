#!/bin/bash

# Install LaTeX packages needed for pandoc PDF generation
# BasicTeX is minimal — these are commonly needed extras

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$_SCRIPT_DIR/../bin:$PATH"
. "$_SCRIPT_DIR/utils.sh"

if ! command -v tlmgr &> /dev/null; then
    error "tlmgr not found. Install BasicTeX first: brew install --cask basictex"
    exit 1
fi

info "Updating tlmgr..."
sudo tlmgr update --self

info "Installing LaTeX packages for pandoc..."
sudo tlmgr install \
    soul \
    collection-fontsrecommended \
    collection-latexrecommended

success "LaTeX packages installed."