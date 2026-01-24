# Dotfiles

Personal development environment configuration for **macOS and Linux**.

**Repository:** [github.com/Rozkalns/dotfiles](https://github.com/Rozkalns/dotfiles)

## Quick Start

```bash
# Clone the repository
git clone git@github.com:Rozkalns/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install everything
make

# Or use the interactive installer
./install.sh
```

## What's Included

### 🎨 Theme
- **Catppuccin Mocha** - Consistent theme across all tools
- Starship, Neovim, Zsh syntax highlighting, btop, WezTerm

### 🐚 Shell
- **Zsh** - Modern shell configuration
- **Starship** - Fast, beautiful prompt with git info
- **Modern CLI tools** - bat, eza, fzf, ripgrep, zoxide, fd
- Syntax highlighting and autosuggestions
- Custom aliases and functions

### ⌨️ Editors
- **Neovim** - Minimal config with Catppuccin theme
- **Vim** - Portable fallback config

### 🖥️ Terminal
- **WezTerm** - GPU-accelerated terminal with Catppuccin
- Configured keybindings (Cmd+K clear, Option+Arrows word jump)

### 🍺 Package Management
- **Homebrew** - Works on macOS and Linux
- **Separate Brewfile/Caskfile** - CLI tools vs GUI apps
- Auto-installs: git, neovim, docker, and more

### 🍎 macOS Configuration
- Comprehensive system defaults (keyboard, trackpad, Finder, Dock)
- Automated Dock setup (Mail, Messages, Calendar, Safari, PhpStorm, etc.)
- Default file associations (PHPStorm for code files)
- Hot corner: Bottom-left locks screen

### 🔧 Utilities
- **bin/** - Helper scripts (is-macos, is-linux, is-executable, etc.)
- **topgrade** - Update everything with one command
- **GNU stow** - Symlink management
- **Makefile** - Task orchestration

## Installation

### Full Installation (macOS)

```bash
make              # Install everything
make macos        # macOS-specific
make link         # Just create symlinks
make brew         # Just install packages
make defaults     # Just apply macOS defaults
```

### Linux Installation

```bash
make              # Auto-detects Linux, skips GUI apps
make linux        # Explicit Linux install
```

### Available Commands

```bash
make              # Full install (auto-detects OS)
make link         # Create symlinks only
make brew         # Install Homebrew packages
make themes       # Install Catppuccin themes
make dock         # Setup Dock (macOS)
make defaults     # Apply macOS defaults
make update       # Update all packages (topgrade)
make unlink       # Remove all symlinks
make test         # Test installation
make help         # Show all commands
```

## Git Aliases

Your git config includes useful aliases:

```bash
git st              # status
git co              # checkout
git br              # branch
git ci              # commit
git amend           # amend last commit
git undo            # undo last commit (keep changes)
git unstage         # unstage files
git publish         # push -u origin HEAD (sets up tracking)
git cleanup         # delete merged branches
git l               # pretty log with graph
git d               # diff
```

## Structure

```
dotfiles/
├── Makefile              # Task orchestration
├── install.sh            # Interactive installer (wrapper for make)
│
├── runcom/               # Files → ~/
│   ├── .zshrc
│   └── .zshenv
│
├── config/               # Files → ~/.config/
│   ├── zsh/              # Shell config
│   ├── nvim/             # Neovim config
│   ├── starship/         # Prompt config
│   ├── wezterm/          # Terminal config
│   ├── git/              # Git config & ignore
│   ├── topgrade/         # Update tool config
│   └── ...
│
├── vim/                  # Vim config → ~/
│   └── .vimrc
│
├── bin/                  # Utility scripts
│   ├── is-macos
│   ├── is-linux
│   ├── is-executable
│   └── ...
│
├── scripts/              # Installation scripts
│   ├── prerequisites.sh
│   ├── brew-install-custom.sh
│   ├── themes.sh
│   └── osx-defaults.sh
│
├── macos/                # macOS-specific
│   ├── dock.sh           # Dock automation
│   └── duti              # File associations
│
└── homebrew/             # Package management
    ├── Brewfile          # CLI tools
    └── Caskfile          # macOS apps
```

## Features

### Automated macOS Setup

**Keyboard & Trackpad:**
- Blazingly fast key repeat
- Tap to click
- Three-finger swipe
- No smart quotes (better for coding)

**Finder:**
- Show hidden files & extensions
- Path bar & status bar visible
- No .DS_Store on network drives
- List view by default

**System:**
- Screenshots → ~/Screenshots
- No boot sound
- No window animations (faster!)
- Battery percentage in menu bar
- Password required immediately after sleep

**Dock:**
- Auto-hide
- Perfect size (48px)
- Bottom-left corner = Lock screen
- No bouncing icons

### Cross-Platform Support

**macOS:**
- Full installation (CLI tools + GUI apps)
- System defaults applied
- Dock automation
- File associations

**Linux:**
- All CLI tools work
- Symlinks created
- Skips GUI apps automatically
- Homebrew installed to /home/linuxbrew

## Customization

### Add New Package

```bash
# Install it
brew install package-name

# Add to Brewfile
echo 'brew "package-name"' >> homebrew/Brewfile

# Or for GUI apps (macOS)
echo 'cask "app-name"' >> homebrew/Caskfile
```

### Modify macOS Defaults

Edit `scripts/osx-defaults.sh` to add/remove preferences.

Find settings to customize:
- [macos-defaults.com](https://macos-defaults.com/)
- Run `defaults read` to see current settings

### Add New Config

1. Add to appropriate directory:
   ```bash
   mkdir -p config/myapp
   cp ~/.config/myapp/config myapp/
   ```

2. Run stow to symlink:
   ```bash
   make link
   ```

## Maintenance

### Update Everything

```bash
make update       # Updates brew, casks, npm, cargo, etc.
# Or
topgrade          # Same thing
```

### Update Brewfile

```bash
brew bundle dump --file=homebrew/Brewfile --force
```

### Remove Symlinks

```bash
make unlink       # Cleanly removes all symlinks
```

## Work Computer Setup

### Important Notes

**Safe to use:**
- ✅ Editor configs (vim, nvim)
- ✅ Shell configs (zsh, aliases)
- ✅ Terminal (wezterm)

**Review before using:**
- ⚠️ Brewfile - Contains personal apps (Spotify, etc.)
- ⚠️ macOS defaults - Changes system preferences
- ⚠️ Computer name prompt - Say "n" to keep company name

### Recommended Approach

```bash
git clone git@github.com:Rozkalns/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Review and edit packages
vim homebrew/Brewfile    # Remove personal apps
vim homebrew/Caskfile    # Remove personal GUI apps

# Install
make

# When prompted for computer name, say 'n'
```

## Migration from v1.0

If you're upgrading from the old dotfiles (custom symlinks.sh):

1. **Remove old symlinks:**
   ```bash
   make unlink
   ```

2. **Create new symlinks:**
   ```bash
   make link
   ```

3. **Reload shell:**
   ```bash
   source ~/.zshrc
   ```

See [docs/MIGRATION.md](docs/MIGRATION.md) for detailed migration guide.

## Testing

```bash
make test         # Verify installation
```

Checks:
- Symlinks created correctly
- Bin utilities in PATH
- Configs accessible

## Troubleshooting

### Symlinks not working

```bash
ls -la ~/.zshrc           # Check if symlink exists
make unlink && make link  # Recreate symlinks
```

### Bin utilities not in PATH

```bash
source ~/.zshrc           # Reload shell
which is-macos            # Should show path
```

### Brew installation fails

```bash
brew doctor               # Check for issues
brew update               # Update Homebrew
```

## Tech Stack

- **Shell:** Zsh with Starship prompt
- **Package Manager:** Homebrew (macOS & Linux)
- **Symlinks:** GNU stow
- **Orchestration:** Makefile
- **Theme:** Catppuccin Mocha
- **Terminal:** WezTerm
- **Editor:** Neovim + Vim
- **CLI Tools:** bat, eza, fzf, ripgrep, fd, zoxide, git-delta

## Credits

Inspired by [webpro/dotfiles](https://github.com/webpro/dotfiles) and modern dotfiles best practices.

## License

Personal configurations. Feel free to use and adapt. No warranty provided.
