# PDF generation via pandoc + xelatex
# Requires: brew install pandoc && brew install --cask basictex
# Optional: npm install -g mermaid-filter (for mermaid diagram support)

pdf() {
    if ! command -v pandoc &> /dev/null; then
        echo "pandoc not installed. Run: brew install pandoc"
        return 1
    fi

    if ! command -v xelatex &> /dev/null; then
        echo "xelatex not installed. Run: brew install --cask basictex && exec zsh"
        return 1
    fi

    local input="$1"

    if [ -z "$input" ]; then
        echo "Usage: pdf <input.md> [output.pdf]"
        echo ""
        echo "Converts Markdown to PDF using pandoc + xelatex."
        echo "Mermaid diagrams are rendered automatically if mermaid-filter is installed."
        echo ""
        echo "Examples:"
        echo "  pdf notes.md                    # -> notes.pdf"
        echo "  pdf notes.md output.pdf         # -> output.pdf"
        echo ""
        echo "Setup:"
        echo "  brew install pandoc && brew install --cask basictex"
        echo "  npm install -g mermaid-filter   # optional, for mermaid diagrams"
        echo ""
        echo "If xelatex complains about a missing .sty package:"
        echo "  sudo tlmgr install <package>"
        return 0
    fi

    if [ ! -f "$input" ]; then
        echo "File not found: $input"
        return 1
    fi

    local output="${2:-${input%.md}.pdf}"
    local filter_args=()

    if command -v mermaid-filter &> /dev/null; then
        filter_args+=(--filter mermaid-filter)
    fi

    pandoc "$input" -o "$output" \
        --pdf-engine=xelatex \
        -V geometry:margin=1in \
        -V monofont="Menlo" \
        "${filter_args[@]}" \
        && echo "Created: $output"
}