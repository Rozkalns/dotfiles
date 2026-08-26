.PHONY: all macos linux link hooks core brew themes dock defaults duti phpstorm topgrade-agent motd git-setup pdf help test sync additional migrate

# Detect OS
UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
	OS := macos
else
	OS := linux
endif

# stow with .DS_Store ignored (--ignore is additive to stow's built-in defaults,
# unlike a .stow-local-ignore file which would replace them)
STOW := stow --ignore='\.DS_Store'

# Default target
all: $(OS)

# macOS installation
macos: core brew link hooks themes dock defaults duti phpstorm topgrade-agent pdf migrate
	@echo "✅ macOS dotfiles installation complete!"
	@echo ""
	@echo "To activate your new shell configuration:"
	@echo "    source ~/.zshrc"
	@echo ""

# Linux installation
linux: core brew link hooks motd migrate
	@echo "✅ Linux dotfiles installation complete!"
	@echo ""
	@echo "To activate your new shell configuration:"
	@echo "    source ~/.zshrc"
	@echo ""

# Pull latest changes and re-apply symlinks
sync:
	@echo "==> Pulling latest dotfiles..."
	@git -C "$(dir $(abspath $(lastword $(MAKEFILE_LIST))))" pull
	@$(MAKE) link
	@$(MAKE) hooks
	@echo "✅ Dotfiles synced. Run 'source ~/.zshrc' to apply shell changes."

# Core setup (bin utilities available)
core:
	@echo "==> Setting up core..."
	@chmod +x bin/*
	@chmod +x scripts/*.sh
	@chmod +x macos/*.sh 2>/dev/null || true
	@chmod +x linux/*.sh 2>/dev/null || true

# Create symlinks using stow
link:
	@echo "==> Creating symbolic links with stow..."
	@command -v stow >/dev/null 2>&1 || { echo "❌ stow not installed. Run 'brew install stow' first."; exit 1; }
	@$(STOW) -t "$$HOME" runcom
	@$(STOW) -t "$$HOME" vim
	@$(STOW) -t "$$HOME" zsh.d
	@$(STOW) -t "$$HOME" dot-claude
	@if [ ! -f "$$HOME/.claude/settings.local.json" ] && [ -f "$$HOME/.claude/settings.local.json.example" ]; then \
		cp "$$HOME/.claude/settings.local.json.example" "$$HOME/.claude/settings.local.json"; \
		echo "  Created ~/.claude/settings.local.json from example (edit for this machine)"; \
	fi
	@$(STOW) -t "$$HOME/.config" config
	@echo "✅ Symlinks created"

# Install git hooks into whichever directory git actually reads.
# core.hooksPath — set globally so the pre-push secret guard applies everywhere —
# replaces .git/hooks entirely rather than adding to it, so installing there
# would be silently dead. The hooks self-limit to this repo; see scripts/hooks/.
hooks:
	@echo "==> Installing git hooks..."
	@dest="$$(git -C "$(CURDIR)" config --get core.hooksPath)"; \
	 [ -n "$$dest" ] || dest="$(CURDIR)/.git/hooks"; \
	 mkdir -p "$$dest"; \
	 ln -sf "$(CURDIR)/scripts/hooks/post-merge" "$$dest/post-merge"; \
	 ln -sf "$(CURDIR)/scripts/hooks/post-rewrite" "$$dest/post-rewrite"; \
	 if [ "$$dest" != "$(CURDIR)/.git/hooks" ]; then \
	   rm -f "$(CURDIR)/.git/hooks/post-merge" "$(CURDIR)/.git/hooks/post-rewrite"; \
	 fi; \
	 echo "✅ Git hooks installed into $$dest"

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

# Apply file associations
duti:
ifeq ($(OS),macos)
	@echo "==> Applying file associations..."
	@command -v duti >/dev/null 2>&1 || { echo "❌ duti not installed. Run 'brew install duti' first."; exit 1; }
	@duti macos/duti
	@echo "✅ File associations applied"
else
	@echo "Skipping file associations (not macOS)"
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

# Install PDF toolchain (LaTeX packages + mermaid-filter)
pdf:
	@echo "==> Setting up PDF toolchain..."
	@./scripts/basictex-packages.sh

# Setup MOTD (Linux)
motd:
ifeq ($(OS),linux)
	@echo "==> Setting up MOTD..."
	@./linux/motd.sh
else
	@echo "Skipping MOTD setup (not Linux)"
endif

# Run pending migrations
migrate:
	@echo "==> Running migrations..."
	@./scripts/migrate.sh

# Setup Git configuration
git-setup:
	@echo "==> Setting up Git configuration..."
	@./scripts/git-setup.sh

# Update everything
update:
	@echo "==> Updating all packages..."
	@command -v topgrade >/dev/null 2>&1 && topgrade || { echo "topgrade not installed, using brew update"; brew update && brew upgrade; }

# Uninstall symlinks
unlink:
	@echo "==> Removing symbolic links..."
	@$(STOW) -t "$$HOME" -D runcom || true
	@$(STOW) -t "$$HOME" -D vim || true
	@$(STOW) -t "$$HOME" -D zsh.d || true
	@$(STOW) -t "$$HOME" -D dot-claude || true
	@$(STOW) -t "$$HOME/.config" -D config || true
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

# Show additional apps that need manual installation
additional:
	@echo ""
	@echo "Additional apps (manual install):"
	@echo ""
	@tail -n +5 additional-apps.md | grep '|' | grep -v '^|[-]' | grep -v '| App' | while IFS='|' read -r _ app desc url _; do \
		app=$$(echo "$$app" | xargs); \
		desc=$$(echo "$$desc" | xargs); \
		url=$$(echo "$$url" | xargs); \
		echo "  $$app - $$desc"; \
		echo "    $$url"; \
	done
	@echo ""

# Help
help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage:"
	@echo "  make              Install everything (auto-detects OS)"
	@echo "  make macos        Install for macOS"
	@echo "  make linux        Install for Linux"
	@echo "  make link         Create symlinks only"
	@echo "  make hooks        Install git hooks"
	@echo "  make brew         Install Homebrew packages only"
	@echo "  make themes       Install Catppuccin themes only"
	@echo "  make dock         Setup Dock only (macOS)"
	@echo "  make defaults     Apply macOS defaults only"
	@echo "  make duti         Apply file associations (macOS)"
	@echo "  make phpstorm     Configure PhpStorm fonts (macOS)"
	@echo "  make topgrade-agent Install Topgrade LaunchAgent (macOS)"
	@echo "  make motd         Install MOTD update reminder (Linux)"
	@echo "  make pdf          Install PDF toolchain (LaTeX + mermaid)"
	@echo "  make migrate      Run pending dotfiles migrations"
	@echo "  make sync         Pull latest changes and re-apply symlinks"
	@echo "  make git-setup    Setup Git user configuration"
	@echo "  make update       Update all packages (uses topgrade)"
	@echo "  make unlink       Remove all symlinks"
	@echo "  make test         Test installation"
	@echo "  make additional    Show apps that need manual installation"
	@echo "  make help         Show this help"
