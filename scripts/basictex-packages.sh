#!/bin/bash

# Install everything needed for pandoc PDF generation:
# - LaTeX packages (via tlmgr, requires BasicTeX)
# - mermaid-cli (via npm, for mermaid diagram support)

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$_SCRIPT_DIR/../bin:$PATH"
. "$_SCRIPT_DIR/utils.sh"

# LaTeX packages
if command -v tlmgr &> /dev/null; then
    info "Updating tlmgr..."
    sudo tlmgr update --self

    info "Installing LaTeX packages for pandoc..."
    sudo tlmgr install \
        soul \
        collection-fontsrecommended \
        collection-latexrecommended

    success "LaTeX packages installed."
else
    error "tlmgr not found. Install BasicTeX first: brew install --cask basictex"
    error "Then restart your shell and re-run this script."
fi

# Mermaid CLI
if command -v npm &> /dev/null; then
    if command -v mmdc &> /dev/null; then
        success "mermaid-cli already installed."
    else
        info "Installing @mermaid-js/mermaid-cli for diagram support..."
        npm install -g @mermaid-js/mermaid-cli
        success "mermaid-cli installed."
    fi
else
    warning "npm not found — skipping mermaid-cli. Install Node.js first if you need diagram support."
fi