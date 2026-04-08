# PDF generation via pandoc + xelatex
# Requires: brew install pandoc && brew install --cask basictex

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
        echo ""
        echo "Examples:"
        echo "  pdf notes.md                    # -> notes.pdf"
        echo "  pdf notes.md output.pdf         # -> output.pdf"
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

    pandoc "$input" -o "$output" \
        --pdf-engine=xelatex \
        -V geometry:margin=1in \
        -V monofont="Menlo" \
        && echo "Created: $output"
}