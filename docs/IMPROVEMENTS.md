# Improvements from webpro/dotfiles

This document tracks improvements inspired by [webpro/dotfiles](https://github.com/webpro/dotfiles).

## ✅ Implemented

### 1. Bin Utilities for Cleaner Scripts
Created utility scripts in `bin/` directory:
- `is-macos` - Check if running on macOS
- `is-linux` - Check if running on Linux
- `is-executable` - Check if command exists
- `is-supported` - Check if command with args is supported
- `is-arm64` - Check if running on Apple Silicon

**Benefits:**
- Cleaner script syntax: `if is-macos; then` vs `if [[ "$OSTYPE" == "darwin"* ]]; then`
- Reusable utilities across all scripts
- Added to PATH in zsh/custom.zsh and all scripts

### 2. Separate Caskfile
Split Brewfile into two files:
- `homebrew/Brewfile` - CLI tools only
- `homebrew/Caskfile` - macOS applications only

**Benefits:**
- Better organization
- Clearer separation of concerns
- Caskfile only processed on macOS

### 3. New Tools Added to Brewfile
- **stow** - GNU Stow for symlink management (future migration)
- **tree** - Directory tree visualization
- **wget** - File downloader
- **topgrade** - Universal package updater
- **dockutil** - Programmatic Dock management (macOS only)
- **duti** - Set default applications (macOS only)

### 4. Dock Automation
Created `macos/dock.sh`:
- Removes all default Dock apps
- Adds preferred apps (Safari, PhpStorm, WezTerm, etc.)
- Prompts during installation
- Run manually: `./macos/dock.sh`

### 5. Default Application Setup (duti)
Created `macos/duti`:
- Sets PhpStorm as default for code files (.php, .js, .json, .md, etc.)
- Prompts during installation
- Run manually: `duti macos/duti`

### 6. Topgrade Configuration
Created `config/topgrade/topgrade.toml`:
- Universal updater configuration
- Updates brew, casks, npm, pip, cargo, etc.
- Run: `topgrade` to update everything

### 7. Enhanced Git Configuration
Created `config/git/config` and `config/git/ignore`:
- Better git aliases (amend, undo, unstage, cleanup, etc.)
- Delta integration for better diffs
- Sensible defaults (rebase on pull, prune on fetch)
- Global gitignore for common files

**To use:**
```bash
# Already symlinked via symlinks.conf
# Or manually include:
git config --global include.path ~/.config/git/config
```

### 8. Updated Install Script
Enhanced `install.sh`:
- Uses bin utilities for cleaner conditionals
- Prompts for Dock configuration
- Prompts for default applications setup
- Better organization and flow

## 📋 Future Enhancements (Optional)

### GNU Stow Migration
Webpro uses GNU Stow instead of custom symlink script. We added `stow` to Brewfile.

**Current:** Custom `scripts/symlinks.sh` + `symlinks.conf`
**Webpro style:** `stow -t "$HOME" runcom` + `stow -t "$XDG_CONFIG_HOME" config`

**When to migrate:**
- When you want simpler symlink management
- Requires directory restructuring

### Makefile Orchestration
Webpro uses a Makefile instead of bash scripts.

**Benefits:**
- Idempotent operations
- Target-based execution
- Easier testing

**Trade-off:** More complex, less approachable for beginners

### Automated Testing
Webpro has automated tests using:
- bats (Bash Automated Testing System)
- GitHub Actions CI
- Weekly testing on macOS 14, 15, Ubuntu

**When to add:**
- When collaborating with others
- When you want confidence in changes
- For learning CI/CD

### More macOS Defaults
Webpro has extensive system defaults (keyboard, trackpad, Finder, Mail, Calendar, etc.)

Currently we have basic defaults. Could expand with:
- Trackpad settings
- Finder preferences
- Keyboard repeat rate
- Screenshot location
- Activity Monitor settings

## Usage

### Install Everything
```bash
./install.sh
```

### Install Only CLI Tools
```bash
brew bundle --file=homebrew/Brewfile
```

### Install Only macOS Apps
```bash
brew bundle --file=homebrew/Caskfile
```

### Setup Dock
```bash
./macos/dock.sh
```

### Set Default Applications
```bash
duti macos/duti
```

### Update Everything
```bash
topgrade
```

### Use Bin Utilities
```bash
# In your scripts
if is-macos; then
    echo "Running on macOS"
fi

if is-executable nvim; then
    echo "Neovim is installed"
fi
```

## Key Differences from webpro/dotfiles

We kept your existing structure while adopting the best ideas:
- ✅ Kept your symlinks.sh (more explicit than stow)
- ✅ Kept your modular script approach
- ✅ Added bin utilities for cleaner code
- ✅ Adopted separate Caskfile
- ✅ Added dock/duti automation
- ✅ Added topgrade for updates
- ✅ Enhanced git configuration

## Testing Checklist

Before committing, test:
- [ ] `./install.sh` runs without errors
- [ ] Bin utilities work: `is-macos && echo "macOS detected"`
- [ ] Brewfile installs: `brew bundle --file=homebrew/Brewfile`
- [ ] Caskfile installs (macOS): `brew bundle --file=homebrew/Caskfile`
- [ ] Dock setup works: `./macos/dock.sh`
- [ ] duti works: `duti macos/duti` (requires PhpStorm installed)
- [ ] Symlinks created: Check `~/.config/git`, `~/.config/topgrade`
- [ ] topgrade works: `topgrade --dry-run`

## References

- [webpro/dotfiles](https://github.com/webpro/dotfiles)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [topgrade](https://github.com/topgrade-rs/topgrade)
- [dockutil](https://github.com/kcrawford/dockutil)
- [duti](https://github.com/moretension/duti)
