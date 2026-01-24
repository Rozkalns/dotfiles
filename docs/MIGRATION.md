# Migration to stow + Makefile

This document explains the v2.0 migration from custom symlink scripts to GNU stow + Makefile.

## What Changed

### Directory Structure

**Before:**
```
dotfiles/
├── zsh/(.zshrc, .zshenv, custom.zsh, aliases.zsh)
├── nvim/
├── starship/
├── wezterm/
├── vim/
└── symlinks.conf
```

**After:**
```
dotfiles/
├── runcom/          # Files → ~/
│   ├── .zshrc
│   └── .zshenv
├── config/          # Files → ~/.config/
│   ├── zsh/(custom.zsh, aliases.zsh)
│   ├── nvim/
│   ├── starship/
│   ├── wezterm/
│   ├── btop/
│   ├── composer/
│   ├── git/
│   └── topgrade/
├── vim/             # Files → ~/
│   └── .vimrc
├── Makefile         # NEW: Orchestration
└── archive/         # OLD: Archived files
    ├── symlinks.conf
    └── symlinks.sh
```

### Installation Method

**Before:**
```bash
./install.sh
```

**After:**
```bash
make              # Full install (auto-detects OS)
make help         # See all commands
./install.sh      # Still works (wrapper around make)
```

## Benefits

### 1. **Relative Symlinks**
Old system created absolute symlinks:
```
~/.zshrc -> /Users/roberts/projects/dotfiles/zsh/.zshrc
```

New system creates relative symlinks:
```
~/.zshrc -> projects/dotfiles/runcom/.zshrc
```

**Why this matters:** Portable across systems, works if you move dotfiles directory.

### 2. **Idempotent Operations**
Can run `make link` multiple times safely - stow handles conflicts gracefully.

### 3. **Modular Commands**
```bash
make link         # Just symlinks
make brew         # Just packages
make defaults     # Just macOS settings
make themes       # Just themes
make update       # Update everything
make unlink       # Remove symlinks
make test         # Test installation
```

### 4. **Standard Convention**
Uses GNU stow - the community standard for dotfiles management.

### 5. **Cleaner Uninstall**
```bash
make unlink       # Removes all symlinks cleanly
```

## Usage

### First-Time Installation

```bash
# Clone the repo
git clone <your-repo> ~/.dotfiles
cd ~/.dotfiles

# Install everything
make

# Or step by step
make brew         # Install packages first
make link         # Create symlinks
make defaults     # Apply macOS defaults
```

### On a New Machine

```bash
# Just the symlinks (if packages already installed)
make link

# Full installation
make
```

### Update Everything

```bash
make update       # Uses topgrade to update all packages
```

### Remove Symlinks

```bash
make unlink       # Cleanly removes all symlinks
```

### Test Installation

```bash
make test         # Verify symlinks are created correctly
```

## Makefile Targets

- `make` or `make all` - Full installation (auto-detects macOS/Linux)
- `make macos` - macOS-specific installation
- `make linux` - Linux-specific installation
- `make link` - Create symlinks only
- `make brew` - Install Homebrew packages only
- `make themes` - Install Catppuccin themes only
- `make dock` - Setup Dock only (macOS)
- `make defaults` - Apply macOS defaults only
- `make update` - Update all packages
- `make unlink` - Remove all symlinks
- `make test` - Test installation
- `make help` - Show help

## How stow Works

stow creates symlinks by "stowing" a directory tree into a target location.

Example:
```bash
# This command:
stow -t $HOME runcom

# Creates:
~/.zshrc -> projects/dotfiles/runcom/.zshrc
~/.zshenv -> projects/dotfiles/runcom/.zshenv
```

The symlinks are relative to the target directory, making them portable.

## Compatibility

### The `install.sh` Still Works

For backward compatibility, `install.sh` is now a wrapper around the Makefile:

```bash
./install.sh      # Interactive installation
                 # Internally calls: make all
```

### Migration from Old Setup

If you're upgrading from the old setup:

1. Remove old absolute symlinks:
   ```bash
   make unlink
   ```

2. Create new relative symlinks:
   ```bash
   make link
   ```

## Archived Files

These files are no longer used but kept for reference:

- `archive/symlinks.conf` - Old symlink configuration
- `archive/symlinks.sh` - Old symlink script

Can be safely deleted in the future if not needed.

## Troubleshooting

### "stow not installed"

```bash
brew install stow
```

### Symlinks not created

Check if old absolute symlinks exist:
```bash
ls -la ~ | grep dotfiles
ls -la ~/.config | grep dotfiles
```

Remove them manually:
```bash
rm ~/.zshrc ~/.vimrc
rm -rf ~/.config/nvim ~/.config/zsh
# etc.
```

Then run:
```bash
make link
```

### "Target already exists" error

stow won't overwrite existing files. Either:
1. Backup and remove the existing file
2. Use `make unlink` first, then `make link`

## Comparison with Old System

| Feature | Old (v1.0) | New (v2.0) |
|---------|------------|------------|
| Symlink manager | Custom script | GNU stow |
| Symlink type | Absolute | Relative |
| Orchestration | Bash script | Makefile |
| Idempotent | No | Yes |
| Modular commands | Limited | Full |
| Uninstall | Manual | `make unlink` |
| Testing | None | `make test` |
| Community standard | Custom | Standard |

## Next Steps After Migration

1. Test the installation:
   ```bash
   make test
   ```

2. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

3. Update README with new commands

4. Consider adding more Makefile targets as needed

## References

- [GNU stow documentation](https://www.gnu.org/software/stow/)
- [Makefile tutorial](https://makefiletutorial.com/)
- [webpro/dotfiles](https://github.com/webpro/dotfiles) - Inspiration for this migration
