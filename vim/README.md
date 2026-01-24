# Vim Configuration

A portable, plugin-free Vim configuration that provides 80% of modern editor functionality without any dependencies. Perfect for quick edits, remote servers, or as a fallback when Neovim isn't available.

## Philosophy

This config enhances Vim's defaults with better keybindings and sensible options, while remaining completely portable - no plugins, no package managers, just pure Vim.

## Key Differences from Default Vim

### Visual Improvements

- **Line Numbers**: Both absolute and relative line numbers enabled for easier navigation
- **Scrolling**: Keeps 8 lines above/below cursor for better context (`scrolloff=8`)
- **Status Bar**: Shows file path, current line, and total lines
- **Cursor Shape**: Line cursor in insert mode, block cursor in normal mode
- **Colorscheme**: Industry theme (dark background)
- **No Clutter**: Swap files, backup files, and search highlighting disabled

### Better Search

- **Case-insensitive** by default (`ignorecase`)
- **Smart case**: Becomes case-sensitive when you type capitals (`smartcase`)
- **Auto-center**: Search results automatically center on screen

### Enhanced Editing

- **Persistent Undo**: Undo history saved between sessions (`undofile`)
- **Smart Indenting**: 4 spaces, tabs converted to spaces
- **Word Wrap**: Doesn't break words mid-wrap (`linebreak`)
- **System Clipboard**: Syncs with macOS/Linux clipboard automatically

## Essential Keybindings

### Leader Key: `Space`

Press Space to access all leader commands.

### Escaping Insert Mode

| Keybinding | Action |
|------------|--------|
| `jk` or `kj` | Exit insert mode (faster than ESC) |

### File Operations

| Keybinding | Action |
|------------|--------|
| `Ctrl+s` | Save file |
| `Leader+sn` | Save without auto-formatting |
| `Ctrl+q` | Quit file |
| `Leader+e` | Open file explorer (Netrw) |

### Navigation

| Keybinding | Action |
|------------|--------|
| `Ctrl+d` | Scroll down half-page and center |
| `Ctrl+u` | Scroll up half-page and center |
| `n` | Find next and center |
| `N` | Find previous and center |
| `j`/`k` | Move down/up through wrapped lines naturally |

### Buffer Management

| Keybinding | Action |
|------------|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `Leader+sb` | Select buffer from list |
| `Leader+x` | Close current buffer |
| `Leader+b` | Open new empty buffer |

### Window Splits

| Keybinding | Action |
|------------|--------|
| `Leader+v` | Vertical split |
| `Leader+h` | Horizontal split |
| `Leader+se` | Make splits equal size |
| `Leader+xs` | Close current split |
| `Ctrl+h/j/k/l` | Navigate between splits (left/down/up/right) |
| `Arrow Keys` | Resize splits |

### Tabs

| Keybinding | Action |
|------------|--------|
| `Leader+to` | Open new tab |
| `Leader+tx` | Close current tab |
| `Leader+tn` | Go to next tab |
| `Leader+tp` | Go to previous tab |

### Editing

| Keybinding | Action |
|------------|--------|
| `x` | Delete character without copying to register |
| `Leader++` | Increment number under cursor |
| `Leader+-` | Decrement number under cursor |
| `Leader+lw` | Toggle line wrapping |

### Visual Mode

| Keybinding | Action |
|------------|--------|
| `<` or `>` | Indent/outdent and stay in visual mode |
| `p` | Paste without overwriting clipboard |

### Clipboard

| Keybinding | Action |
|------------|--------|
| `Leader+y` | Yank to system clipboard (visual selection) |
| `Leader+Y` | Yank entire line to system clipboard |

## File Explorer (Netrw)

Press `Leader+e` to open the built-in file explorer with these improvements:

- Opens in left sidebar (25% width)
- Tree-style listing
- Banner hidden for cleaner look
- Press `l` to open files (in addition to Enter)
- Press `h` to go up a directory

## Why Use This Over Default Vim?

**Default Vim Requires:**
- Reaching for ESC constantly
- Remembering `:w`, `:q` commands
- Manual `"+y` for system clipboard
- No persistent undo
- Awkward window navigation

**This Config Provides:**
- `jk` to exit insert mode (home row!)
- `Ctrl+s`/`Ctrl+q` like modern editors
- Automatic clipboard sync
- Undo history that survives restarts
- Intuitive split navigation with Ctrl+hjkl

## Installation

This config is automatically installed via the main dotfiles install script, which symlinks `~/.vimrc` to this file.

Manual installation:
```bash
ln -s $(pwd)/vim/.vimrc ~/.vimrc
```

## When to Use This vs Neovim

**Use Vim (.vimrc):**
- Remote servers (SSH)
- Quick edits
- When Neovim isn't installed
- Maximum portability needed
- Minimal resource usage

**Use Neovim:**
- Daily development work
- Need LSP/autocomplete
- Want modern IDE features
- Git integration required
- Fuzzy finding large codebases
