# Dotfiles

Personal development environment configuration for **macOS and Linux**. These dotfiles help maintain a consistent setup across different machines and make setting up a new computer painless.

Powered by Homebrew (which works on both macOS and Linux!), these configs are portable across platforms with minimal differences.

## What's Included

### Shell Configuration
- **Zsh** - Shell configuration with custom aliases and functions
  - Custom prompt with Starship
  - Syntax highlighting and autosuggestions
  - FZF integration for fuzzy finding
  - Zoxide for smarter directory navigation
  - Vi mode keybindings
  - Herd (PHP), Pyenv (Python), NVM (Node) integration

### Editor Configurations
- **Neovim** - Full IDE setup with LSP, fuzzy finding, git integration
  - See [nvim/README.md](nvim/README.md) for detailed features
- **Vim** - Portable, plugin-free config for quick edits
  - See [vim/README.md](vim/README.md) for features

### Terminal & UI
- **WezTerm** - Modern, GPU-accelerated terminal emulator
- **Starship** - Fast, customizable prompt
- **btop** - System resource monitor
- **Composer** - PHP dependency manager config

### Scripts & Automation
- **install.sh** - Main installation script
- **scripts/prerequisites.sh** - Installs Xcode CLI tools & Homebrew
- **scripts/brew-install-custom.sh** - Manages Homebrew packages
- **scripts/osx-defaults.sh** - Applies macOS system preferences
- **scripts/symlinks.sh** - Creates/removes symlinks

### Application & Tool Installation
- **Homebrew/Brewfile** - All packages and applications to install
  - CLI tools (git, neovim, fzf, ripgrep, etc.)
  - GUI applications (Docker, Raycast, Rectangle, etc.)
  - Development tools (Herd, Claude Code, etc.)

## Quick Start

### Fresh macOS Setup

```bash
# Clone this repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# Run the installation script
./install.sh
```

The script will ask:
- **Install apps?** [y/n] - Answer `y` on fresh install to install all Homebrew packages
- **Overwrite existing dotfiles?** [y/n] - Answer `y` on fresh install to replace existing configs

### What the Install Script Does

1. **Prerequisites** (if you answer `y` to install apps)
   - Installs Xcode Command Line Tools
   - Installs Homebrew package manager

2. **Applications** (if you answer `y` to install apps)
   - Runs `brew bundle` to install all packages from `homebrew/Brewfile`
   - Installs CLI tools (git, neovim, fzf, etc.)
   - Installs GUI apps (Docker, Raycast, etc.)

3. **macOS System Defaults**
   - Disables key repeat delay (faster key repeats)
   - Hides desktop icons and drives
   - Shows hidden files in Finder
   - Shows path bar and status bar in Finder
   - Sets Dock to auto-hide
   - Configures Rectangle window management
   - And more... (see `scripts/osx-defaults.sh`)

4. **Terminal Setup**
   - Creates `~/.hushlogin` to suppress login messages

5. **Symlinks**
   - Creates symbolic links from dotfiles to their proper locations
   - See `symlinks.conf` for the complete list

### Fresh Linux/Ubuntu Setup

```bash
# Clone this repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# Run the same installation script!
./install.sh
```

**What works on Linux:**
- ✅ All CLI tools (bat, eza, fd, fzf, ripgrep, neovim, etc.)
- ✅ Vim and Neovim configs
- ✅ Zsh configuration with all plugins
- ✅ Starship prompt
- ✅ Shell aliases and functions

**What's skipped on Linux:**
- ⏭️ GUI apps (casks) - Linux doesn't use Homebrew casks
- ⏭️ macOS system defaults - Linux has different system settings

**Note:** Homebrew works on Linux! The script will:
1. Install build dependencies (gcc, make, etc.)
2. Install Homebrew to `/home/linuxbrew/.linuxbrew`
3. Install all CLI tools from the Brewfile
4. Skip GUI apps automatically
5. Symlink all portable configs

## Using on Multiple Machines

### Updating Existing Setup

If you already have these dotfiles set up and want to pull updates:

```bash
cd ~/dotfiles
git pull

# Only update symlinks, skip app installation
./install.sh
# Answer 'n' to "Install apps?"
# Answer 'n' to "Overwrite existing dotfiles?" (unless you want to replace)
```

### Work vs Personal Mac

**⚠️ IMPORTANT: Read Before Installing on Work Computer**

These dotfiles are safe to use on work computers **with some considerations**:

#### Safe to Install
✅ **Editor configs** (vim, nvim) - No security concerns
✅ **Shell configs** (zsh) - Just productivity improvements
✅ **Terminal config** (wezterm) - Safe customization

#### Requires Review
⚠️ **Brewfile** - Contains personal apps you may not want/need at work:
- `claude-code` - Personal AI tool
- `spotify` - Music streaming
- `superwhisper` - Personal transcription app
- `winbox` - Networking tool
- Consider editing `homebrew/Brewfile` before running install

⚠️ **OSX Defaults** - Changes system preferences:
- Shows hidden files (might reveal config files)
- Modifies Dock and Finder behavior
- Your work IT might have specific settings
- Review `scripts/osx-defaults.sh` first

#### Must Customize
❌ **Git Config** - Likely needs different email/credentials
- Update `zsh/custom.zsh` or create work-specific config
- Use different git user.email for work repos

#### Recommended Approach for Work Mac

```bash
# 1. Clone the repo
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# 2. Edit the Brewfile to remove personal apps
vim homebrew/Brewfile  # Remove spotify, superwhisper, etc.

# 3. Review OSX defaults
vim scripts/osx-defaults.sh  # Comment out any changes you don't want

# 4. Run install script
./install.sh
# Answer 'y' or 'n' to app installation based on your needs
# Answer 'y' to overwrite dotfiles
```

Alternatively, you can selectively install:

```bash
# Just symlink configs without installing apps or changing system settings
./scripts/symlinks.sh --create

# Or manually symlink specific configs
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/vim/.vimrc ~/.vimrc
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
```

## File Structure

```
dotfiles/
├── README.md                      # This file
├── install.sh                     # Main installation script
├── symlinks.conf                  # Symlink definitions
│
├── zsh/                          # Zsh configuration
│   ├── .zshrc                    # Main zsh config
│   ├── custom.zsh                # Custom functions and settings
│   ├── aliases.zsh               # Command aliases
│   └── git-completion.*          # Git completion scripts
│
├── nvim/                         # Neovim configuration
│   ├── README.md                 # Neovim setup guide
│   ├── init.lua                  # Main config entry point
│   └── lua/                      # Lua configuration files
│       ├── core/                 # Core options and keymaps
│       └── plugins/              # Plugin configurations
│
├── vim/                          # Vim configuration
│   ├── README.md                 # Vim setup guide
│   └── .vimrc                    # Portable vim config
│
├── starship/                     # Starship prompt
│   └── starship.toml             # Prompt configuration
│
├── wezterm/                      # WezTerm terminal
│   └── wezterm.lua               # Terminal configuration
│
├── btop/                         # System monitor
│   └── themes/                   # btop themes
│
├── composer/                     # PHP Composer
│   └── .htaccess                 # Composer config
│
├── homebrew/                     # Homebrew packages
│   └── Brewfile                  # All packages to install
│
├── scripts/                      # Installation scripts
│   ├── utils.sh                  # Helper functions (colors, logging)
│   ├── prerequisites.sh          # Xcode & Homebrew installer
│   ├── brew-install-custom.sh    # Homebrew package installer
│   ├── osx-defaults.sh           # macOS system preferences
│   └── symlinks.sh               # Symlink manager
│
└── docs/                         # Documentation
    └── ideas/                    # Design drafts
```

## Customization

### Adding New Dotfiles

1. Add your config file to the appropriate directory:
   ```bash
   mkdir -p mynewapp
   cp ~/.config/mynewapp/config.conf mynewapp/
   ```

2. Add symlink entry to `symlinks.conf`:
   ```
   $(pwd)/mynewapp/config.conf:$HOME/.config/mynewapp/config.conf
   ```

3. Test the symlink:
   ```bash
   ./scripts/symlinks.sh --create
   ```

### Adding New Applications

1. Install the app via Homebrew:
   ```bash
   brew install <package>
   # or
   brew install --cask <app>
   ```

2. Add to `homebrew/Brewfile`:
   ```ruby
   brew "package-name"
   # or
   cask "app-name"
   ```

3. Regenerate Brewfile from current system (optional):
   ```bash
   brew bundle dump --file=homebrew/Brewfile --force
   ```

### Modifying macOS Defaults

Edit `scripts/osx-defaults.sh` to add or remove system preferences:

```bash
# Example: Change Dock size
defaults write com.apple.dock tilesize -float 48
```

Find more defaults to customize:
- [macos-defaults.com](https://macos-defaults.com/)
- Run `defaults read` to see current settings
- Change a setting in System Preferences, then run `defaults read > before.txt`, change it back, run `defaults read > after.txt`, and `diff` them

## Maintenance

### Updating Brewfile

To capture your current Homebrew installations:

```bash
cd ~/dotfiles
brew bundle dump --file=homebrew/Brewfile --force
```

### Removing Symlinks

To remove all symlinks (but keep the actual config files):

```bash
./scripts/symlinks.sh --delete
```

To also delete the actual config files (be careful!):

```bash
./scripts/symlinks.sh --delete --include-files
```

### Backing Up Before Changes

Always back up before making major changes:

```bash
# Backup entire config directory
cp -r ~/.config ~/.config.backup

# Backup specific configs
cp ~/.zshrc ~/.zshrc.backup
cp -r ~/.config/nvim ~/.config/nvim.backup
```

## Key Tools & Technologies

### Command Line Tools
- **Homebrew** - Package manager for macOS
- **Zsh** - Modern shell (macOS default)
- **Starship** - Cross-shell prompt
- **FZF** - Fuzzy finder for files and commands
- **Ripgrep** - Fast recursive search
- **Zoxide** - Smarter cd command
- **Git** - Version control
- **Neovim** - Modern Vim-based editor

### Development Tools
- **Herd** - PHP development environment
- **Pyenv** - Python version manager
- **NVM** - Node.js version manager
- **Docker Desktop** - Container platform
- **Git Delta** - Better git diffs

### GUI Applications
- **WezTerm** - GPU-accelerated terminal
- **Raycast** - Spotlight replacement
- **Rectangle** - Window management
- **Hiddenbar** - Hide menu bar items
- **Claude Code** - AI coding assistant

## Troubleshooting

### Symlinks not working

```bash
# Check if symlink exists
ls -la ~/.zshrc

# Remove broken symlink
rm ~/.zshrc

# Recreate symlinks
cd ~/dotfiles
./scripts/symlinks.sh --create
```

### Homebrew installation fails

```bash
# Update Homebrew
brew update

# Check for issues
brew doctor

# Reinstall specific package
brew reinstall <package>
```

### Shell config not loading

```bash
# Check for syntax errors
zsh -n ~/.zshrc

# Source config manually
source ~/.zshrc

# Check what's being loaded
zsh -x ~/.zshrc 2>&1 | less
```

### Neovim plugins not installing

```bash
# Open Neovim
nvim

# Install plugins
:Lazy sync

# Check for errors
:Lazy health
:checkhealth
```

## Philosophy

These dotfiles follow these principles:

1. **Portable** - Work on any Mac with minimal dependencies
2. **Modular** - Each tool's config is independent
3. **Documented** - READMEs explain what each config does
4. **Safe** - Backs up before making changes, easy to revert
5. **Automated** - One command to set up everything
6. **Transparent** - Scripts are readable and well-commented

## Credits

Inspired by various dotfiles repositories and customized for personal workflow. The Neovim configuration is based on modern Lua practices and the vim config provides a solid fallback.

## License

These are personal configurations, but feel free to use and adapt them for your own needs. No warranty provided - use at your own risk!

## Contributing

This is a personal configuration, but if you find bugs or have suggestions, feel free to open an issue or submit a pull request.
