#!/usr/bin/env bash

# PhpStorm Configuration Script
# Sets up JetBrains Mono Nerd Font for editor and terminal

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}Warning:${NC} $1"; }
error() { echo -e "${RED}Error:${NC} $1"; }

# Check if PhpStorm is installed
if [ ! -d "/Applications/PhpStorm.app" ]; then
    warn "PhpStorm not found at /Applications/PhpStorm.app"
    echo "Skipping PhpStorm configuration"
    exit 0
fi

info "Configuring PhpStorm..."

# Find PhpStorm config directory (latest version)
PHPSTORM_CONFIG_BASE="$HOME/Library/Application Support/JetBrains"

if [ ! -d "$PHPSTORM_CONFIG_BASE" ]; then
    warn "PhpStorm config directory not found at $PHPSTORM_CONFIG_BASE"
    echo "Please run PhpStorm at least once before running this script"
    exit 0
fi

# Find the latest PhpStorm directory
PHPSTORM_DIR=$(find "$PHPSTORM_CONFIG_BASE" -maxdepth 1 -type d -name "PhpStorm*" | sort -V | tail -1)

if [ -z "$PHPSTORM_DIR" ]; then
    warn "No PhpStorm configuration directory found"
    echo "Please run PhpStorm at least once before running this script"
    exit 0
fi

info "Found PhpStorm config: $(basename "$PHPSTORM_DIR")"

# Create options directory if it doesn't exist
OPTIONS_DIR="$PHPSTORM_DIR/options"
mkdir -p "$OPTIONS_DIR"

# Configure editor font (editor-font.xml)
EDITOR_FONT_XML="$OPTIONS_DIR/editor-font.xml"

info "Configuring editor font..."

cat > "$EDITOR_FONT_XML" << 'EOF'
<application>
  <component name="DefaultFont">
    <option name="VERSION" value="1" />
    <option name="FONT_FAMILY" value="JetBrainsMono Nerd Font" />
    <option name="FONT_REGULAR_SUB_FAMILY" value="Regular" />
    <option name="FONT_BOLD_SUB_FAMILY" value="Bold" />
    <option name="FONT_SIZE" value="13" />
    <option name="FONT_SIZE_2D" value="13.0" />
    <option name="LINE_SPACING" value="1.2" />
  </component>
</application>
EOF

# Configure terminal font (terminal-font.xml)
TERMINAL_FONT_XML="$OPTIONS_DIR/terminal-font.xml"

info "Configuring terminal font..."

cat > "$TERMINAL_FONT_XML" << 'EOF'
<application>
  <component name="TerminalFontOptions">
    <option name="VERSION" value="1" />
    <option name="FONT_FAMILY" value="JetBrainsMono Nerd Font" />
    <option name="FONT_SIZE" value="13" />
    <option name="LINE_SPACING" value="1.2" />
    <option name="SECONDARY_FONT_FAMILY" />
  </component>
</application>
EOF

# Configure console font (console-font.xml)
CONSOLE_FONT_XML="$OPTIONS_DIR/console-font.xml"

info "Configuring console font..."

cat > "$CONSOLE_FONT_XML" << 'EOF'
<application>
  <component name="ConsoleFont">
    <option name="VERSION" value="1" />
    <option name="FONT_FAMILY" value="JetBrainsMono Nerd Font" />
    <option name="FONT_SIZE" value="13" />
    <option name="LINE_SPACING" value="1.2" />
  </component>
</application>
EOF

info "✅ PhpStorm configuration complete!"
echo ""
echo "Settings applied:"
echo "  • Editor font: JetBrainsMono Nerd Font (13pt, line spacing 1.2)"
echo "  • Terminal font: JetBrainsMono Nerd Font (13pt, line spacing 1.2)"
echo "  • Console font: JetBrainsMono Nerd Font (13pt, line spacing 1.2)"
echo ""
echo "⚠️  Please restart PhpStorm for changes to take effect."
