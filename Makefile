.PHONY: all macos linux link core brew themes dock defaults phpstorm topgrade-agent help test

# Detect OS
UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
	OS := macos
else
	OS := linux
endif

# Default target
all: $(OS)

# macOS installation
macos: core link brew themes dock defaults phpstorm topgrade-agent
	@echo "✅ macOS dotfiles installation complete!"
	@echo ""
	@echo "To activate your new shell configuration:"
	@echo "    source ~/.zshrc"
	@echo ""

# Linux installation
linux: core link
	@echo "✅ Linux dotfiles installation complete!"
	@echo ""
	@echo "To activate your new shell configuration:"
	@echo "    source ~/.zshrc"
	@echo ""

# Core setup (bin utilities available)
core:
	@echo "==> Setting up core..."
	@chmod +x bin/*
	@chmod +x scripts/*.sh
	@chmod +x macos/*.sh

# Create symlinks using stow
link:
	@echo "==> Creating symbolic links with stow..."
	@command -v stow >/dev/null 2>&1 || { echo "❌ stow not installed. Run 'brew install stow' first."; exit 1; }
	@stow -t "$$HOME" runcom
	@stow -t "$$HOME" vim
	@stow -t "$$HOME/.config" config
	@echo "✅ Symlinks created"

# Install Homebrew packages
brew:
	@echo "==> Installing Homebrew packages..."
	@./scripts/prerequisites.sh
	@./scripts/brew-install-custom.sh

# Install themes
themes:
	@echo "==> Installing Catppuccin themes..."
	@./scripts/themes.sh

# Setup Dock (macOS only)
dock:
ifeq ($(OS),macos)
	@echo "==> Setting up Dock..."
	@read -p "Configure Dock with preferred apps? [y/n] " answer; \
	if [ "$$answer" = "y" ]; then \
		./macos/dock.sh; \
	else \
		echo "Skipping Dock setup"; \
	fi
else
	@echo "Skipping Dock setup (not macOS)"
endif

# Apply macOS defaults
defaults:
ifeq ($(OS),macos)
	@echo "==> Applying macOS system defaults..."
	@./scripts/osx-defaults.sh
else
	@echo "Skipping macOS defaults (not macOS)"
endif

# Configure PhpStorm
phpstorm:
ifeq ($(OS),macos)
	@echo "==> Configuring PhpStorm..."
	@./macos/phpstorm.sh
else
	@echo "Skipping PhpStorm configuration (not macOS)"
endif

# Setup Topgrade LaunchAgent
topgrade-agent:
ifeq ($(OS),macos)
	@echo "==> Setting up Topgrade LaunchAgent..."
	@./macos/topgrade-launchagent.sh
else
	@echo "Skipping Topgrade LaunchAgent (not macOS)"
endif

# Update everything
update:
	@echo "==> Updating all packages..."
	@command -v topgrade >/dev/null 2>&1 && topgrade || { echo "topgrade not installed, using brew update"; brew update && brew upgrade; }

# Uninstall symlinks
unlink:
	@echo "==> Removing symbolic links..."
	@stow -t "$$HOME" -D runcom || true
	@stow -t "$$HOME" -D vim || true
	@stow -t "$$HOME/.config" -D config || true
	@echo "✅ Symlinks removed"

# Test installation
test:
	@echo "==> Testing installation..."
	@echo "Checking symlinks..."
	@test -L "$$HOME/.zshrc" && echo "✅ .zshrc linked" || echo "❌ .zshrc not linked"
	@test -L "$$HOME/.config/zsh/custom.zsh" && echo "✅ custom.zsh linked" || echo "❌ custom.zsh not linked"
	@test -L "$$HOME/.config/nvim" && echo "✅ nvim linked" || echo "❌ nvim not linked"
	@test -L "$$HOME/.vimrc" && echo "✅ .vimrc linked" || echo "❌ .vimrc not linked"
	@echo ""
	@echo "Checking bin utilities..."
	@command -v is-macos >/dev/null 2>&1 && echo "✅ bin utilities in PATH" || echo "❌ bin utilities not in PATH"

# Help
help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage:"
	@echo "  make              Install everything (auto-detects OS)"
	@echo "  make macos        Install for macOS"
	@echo "  make linux        Install for Linux"
	@echo "  make link         Create symlinks only"
	@echo "  make brew         Install Homebrew packages only"
	@echo "  make themes       Install Catppuccin themes only"
	@echo "  make dock         Setup Dock only (macOS)"
	@echo "  make defaults     Apply macOS defaults only"
	@echo "  make phpstorm     Configure PhpStorm fonts (macOS)"
	@echo "  make topgrade-agent Install Topgrade LaunchAgent (macOS)"
	@echo "  make update       Update all packages (uses topgrade)"
	@echo "  make unlink       Remove all symlinks"
	@echo "  make test         Test installation"
	@echo "  make help         Show this help"
