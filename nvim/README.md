# Simple Neovim Configuration

This is a **minimal, easy-to-understand** Neovim config. Perfect for learning!

## What's Included

✅ **Basic editing features:**
- Line numbers (relative and absolute)
- Smart search (case-insensitive unless you use capitals)
- Auto-indent
- System clipboard integration

✅ **Essential keybindings:**
- `Space` is your leader key (like a command prefix)
- `Ctrl+s` to save, `Ctrl+q` to quit
- `jk` or `kj` to exit insert mode (faster than ESC)
- `Space+e` to toggle file explorer
- `Tab`/`Shift+Tab` to switch between open files
- `Ctrl+h/j/k/l` to navigate between split windows

✅ **Minimal plugins:**
- **lazy.nvim** - Plugin manager (auto-installs on first run)
- **Catppuccin** - Beautiful color scheme
- Just one file: `init.lua`
- Fast startup

## Quick Reference

### Leader Key Commands
(Press `Space` then the key)

| Key | Action |
|-----|--------|
| `e` | Toggle file explorer |
| `v` | Split window vertically |
| `h` | Split window horizontally |
| `x` | Close current file/buffer |
| `b` | Open new empty buffer |
| `y` | Copy to system clipboard (visual mode) |

### Navigation
| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between splits |
| `Tab` | Next file |
| `Shift+Tab` | Previous file |
| `Ctrl+d/u` | Scroll half-page down/up (and center) |

### Editing
| Key | Action |
|-----|--------|
| `jk` or `kj` | Exit insert mode |
| `Ctrl+s` | Save file |
| `Ctrl+q` | Quit |
| `>` / `<` | Indent/outdent (in visual mode, stays in visual) |

## Customizing the Theme

Catppuccin has 4 flavors (change in `init.lua` line with `flavour = "mocha"`):

- **latte** - Light theme (for daytime coding)
- **frappe** - Dark with blue tones
- **macchiato** - Darker
- **mocha** - Darkest (default) ← You're using this!

Preview all flavors: https://github.com/catppuccin/nvim

## Adding Features Later

Your complex config is backed up in `nvim-complex-backup/`.

**When you want to add features:**

1. **Plugin Manager**: Add `lazy.nvim` for installing plugins
2. **LSP**: Add language servers for autocomplete & error checking
3. **Telescope**: Fuzzy finder for files
4. **Treesitter**: Better syntax highlighting
5. **Color Schemes**: Install themes like Nord or Catppuccin

For now, **learn the basics** with this simple config!

## Learning Resources

- `:help` - Neovim's built-in help (try `:help keymaps`)
- `:Tutor` - Interactive Neovim tutorial
- [Neovim Kickstart](https://github.com/nvim-lua/kickstart.nvim) - Simple starting point

## Switching to Complex Config

Want the full IDE experience back?

```bash
cd ~/projects/dotfiles
rm -rf nvim
mv nvim-complex-backup nvim
```

Then fix the issues we had and it'll work!
