# Complex Neovim Configuration (Backup)

> **Note:** This is a backup of a full-featured IDE-like Neovim setup with 50+ plugins. It was replaced with a simpler config (see `../nvim/`) for learning purposes. This README is kept as reference for when you want to add more features later.

---

## Original Description

A modern, IDE-like Neovim configuration built with Lua and lazy.nvim plugin manager. Provides VS Code-level features while staying in the terminal.

## Features at a Glance

✅ **LSP Integration** - IntelliSense-style autocomplete, go-to-definition, error checking
✅ **Fuzzy Finding** - Search files and text across your entire project instantly
✅ **Git Integration** - View diffs, stage hunks, see blame inline
✅ **Syntax Highlighting** - Treesitter-based, understands code structure
✅ **Modern UI** - Tab bar, file tree, status line, startup dashboard
✅ **Theme Support** - Nord and OneDark themes (switch via `NVIM_THEME` env var)

## Philosophy

This config transforms Neovim into a full-featured IDE while maintaining Vim's efficiency. All keybindings inherit from the base `.vimrc` config with additional plugin-specific shortcuts.

## Installation

First-time setup:
```bash
# Symlink is created by main install script
# On first launch, lazy.nvim will auto-install all plugins
nvim
```

The config will automatically:
1. Install lazy.nvim plugin manager
2. Download and install all plugins
3. Set up LSP servers
4. Configure themes

## Included Plugins

### Core IDE Features

#### **Telescope** - Fuzzy Finder
Blazing fast fuzzy finder for files, text, git history, and more.

**Keybindings:**
- `Leader+sf` - Search files by name
- `Leader+sg` - Search text in all files (live grep)
- `Leader+sb` - Search open buffers
- `Leader+sh` - Search help tags
- `Leader+sr` - Search recent files
- `Leader+sk` - Search keymaps
- `Leader+/` - Fuzzy search in current buffer

**Usage:**
```
1. Press <Space>sf
2. Type part of filename
3. Use Ctrl+j/k to navigate results
4. Press Enter to open
```

#### **LSP (Language Server Protocol)** - Code Intelligence
Provides IDE-level code understanding for multiple languages.

**Supported Languages:**
- Python, JavaScript, TypeScript, Lua, Go, Rust, PHP, etc.

**Features:**
- **Autocomplete** - Suggestions while typing
- **Go to Definition** - `gd` - Jump to function/class definition
- **Hover Docs** - `K` - View documentation
- **Rename Symbol** - `Leader+rn` - Rename variable/function everywhere
- **Code Actions** - `Leader+ca` - Apply fixes (import, generate code)
- **Format** - `Leader+f` - Auto-format code
- **Diagnostics** - Real-time error/warning checking

**Keybindings:**
- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - Go to references
- `gI` - Go to implementation
- `K` - Hover documentation
- `Leader+rn` - Rename symbol
- `Leader+ca` - Code actions
- `Leader+D` - Type definition
- `[d` / `]d` - Previous/next diagnostic
- `Leader+do` - Toggle diagnostics on/off

#### **Treesitter** - Advanced Syntax Highlighting
Understands code structure, not just keywords. Better highlighting, indentation, and text objects.

**Features:**
- Accurate syntax highlighting
- Incremental selection
- Code folding

#### **Autocompletion (nvim-cmp)**
Intelligent autocomplete as you type, powered by LSP.

**Keybindings (in completion menu):**
- `Ctrl+n` / `Ctrl+p` - Next/previous suggestion
- `Ctrl+b` / `Ctrl+f` - Scroll docs
- `Ctrl+Space` - Trigger completion
- `Enter` - Confirm selection
- `Tab` - Select next item and navigate snippets

**Sources:**
- LSP (functions, variables)
- Buffer words (current file)
- File paths
- Snippets

### File Management

#### **Neo-tree** - File Explorer
Modern file tree with git status indicators.

**Keybindings:**
- `Leader+e` - Toggle file explorer
- `a` - Add file/folder
- `d` - Delete
- `r` - Rename
- `y` - Copy
- `x` - Cut
- `p` - Paste

#### **Bufferline** - Tab Bar
Shows open files as tabs at the top.

**Features:**
- Click to switch buffers
- Shows file icons
- Groups by tabs
- Close buttons

**Keybindings:**
- `Tab` / `Shift+Tab` - Next/previous buffer
- `Leader+x` - Close buffer

### Git Integration

#### **Gitsigns** - Git Diff in Gutter
Shows git status for each line (added, modified, deleted).

**Keybindings:**
- `]c` / `[c` - Next/previous git hunk
- `Leader+hs` - Stage hunk
- `Leader+hr` - Reset hunk
- `Leader+hS` - Stage buffer
- `Leader+hu` - Undo stage hunk
- `Leader+hp` - Preview hunk
- `Leader+hb` - Blame line
- `Leader+hd` - Diff this
- `Leader+td` - Toggle deleted

**Visual Mode:**
- `Leader+hs` - Stage selected lines
- `Leader+hr` - Reset selected lines

#### **Fugitive** - Git Commands
Run git commands from within Neovim.

**Commands:**
- `:Git` - Run any git command
- `:Git blame` - View file blame
- `:Git diff` - View changes
- `:Gwrite` - Stage current file
- `:Gread` - Checkout current file

### UI Enhancements

#### **Lualine** - Status Line
Beautiful status bar showing:
- Current mode (Normal/Insert/Visual)
- Git branch
- File name and type
- Diagnostics count (errors/warnings)
- Cursor position
- File encoding

#### **Alpha** - Dashboard
Startup dashboard showing:
- Recent files
- Quick actions
- Custom header

#### **Which-key** - Keybinding Helper
Shows available keybindings when you pause.

**Usage:**
```
1. Press <Space> (leader key)
2. Wait ~300ms
3. Popup shows all available Space commands
```

### Code Editing

#### **Autopairs** - Auto-close Brackets
Automatically closes brackets, quotes, and tags.

**Examples:**
- Type `(` → Adds `)`
- Type `"` → Adds `"`
- Type `{` → Adds `}`

#### **Comment** - Easy Commenting
Toggle comments with simple keybindings.

**Keybindings:**
- `gcc` - Toggle comment on current line
- `gc` (visual mode) - Toggle comment on selection
- `gbc` - Toggle block comment

#### **Todo Comments** - Highlight TODOs
Highlights special comments:
- `TODO:` - Things to do (blue)
- `FIXME:` - Things to fix (red)
- `NOTE:` - Important notes (green)
- `HACK:` - Temporary hacks (orange)
- `WARNING:` - Warnings (yellow)

**Keybindings:**
- `]t` / `[t` - Next/previous todo comment
- `Leader+st` - Search all todos (Telescope)

#### **TS-Autotag** - Auto-close HTML Tags
Automatically closes HTML/JSX tags.

**Example:**
```html
Type: <div>
Result: <div>|</div>
```

#### **Colorizer** - Color Highlighting
Shows actual colors for hex codes, rgb, etc.

**Examples:**
- `#FF5733` - Shows with orange background
- `rgb(255, 87, 51)` - Shows with orange background

#### **Indent Blankline** - Indentation Guides
Shows vertical lines for indentation levels.

### Development Tools

#### **None-ls** - Formatting & Linting
Code formatting and linting integration.

**Keybindings:**
- `Leader+f` - Format current file

**Supported:**
- Prettier (JS/TS/CSS/HTML)
- Black (Python)
- Stylua (Lua)
- And many more...

#### **Debug Adapter Protocol (DAP)**
Built-in debugger support.

**Features:**
- Set breakpoints
- Step through code
- Inspect variables
- Debug console

#### **Database** - SQL Integration
Interact with databases from Neovim.

**Features:**
- Connect to PostgreSQL, MySQL, SQLite
- Run queries
- View results

### Tmux Integration

#### **vim-tmux-navigator**
Seamless navigation between Neovim splits and Tmux panes.

**Keybindings:**
- `Ctrl+h/j/k/l` - Navigate splits/panes

## Theme Configuration

Switch themes via environment variable in your `.zshenv`:

```bash
# In ~/.zshenv
export NVIM_THEME="nord"    # Nord theme (default)
# or
export NVIM_THEME="onedark" # OneDark theme
```

**Available Themes:**
- `nord` - Bluish, calm theme based on Arctic colors
- `onedark` - Atom's iconic dark theme

## File Structure

```
nvim/
├── init.lua                 # Main entry point
├── lazy-lock.json          # Plugin version lock file
├── lua/
│   ├── core/
│   │   ├── options.lua     # Vim options (like .vimrc)
│   │   ├── keymaps.lua     # Keybindings
│   │   └── snippets.lua    # Custom code snippets
│   └── plugins/
│       ├── telescope.lua   # Fuzzy finder config
│       ├── lsp.lua         # LSP config
│       ├── treesitter.lua  # Syntax highlighting
│       ├── neo-tree.lua    # File explorer
│       ├── lualine.lua     # Status line
│       ├── bufferline.lua  # Tab bar
│       ├── gitsigns.lua    # Git integration
│       └── ...             # And many more
└── README.md              # This file
```

## Essential Keybindings Reference

All keybindings from `.vimrc` work here, plus these plugin-specific ones:

### File Navigation
- `Space+sf` - Find files
- `Space+sg` - Search in files
- `Space+e` - Toggle file tree

### Code Navigation
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Show docs
- `[d` / `]d` - Next/prev error

### Git
- `]c` / `[c` - Next/prev change
- `Space+hs` - Stage hunk
- `Space+hp` - Preview change

### Editing
- `gcc` - Toggle comment
- `Space+f` - Format code
- `Space+ca` - Code actions

### UI
- `Space+e` - File tree
- `Tab` / `S-Tab` - Switch buffers

## When to Use This vs Vim

**Use Neovim (this config):**
- Daily development work
- Need autocomplete and error checking
- Working on large codebases (fuzzy finding)
- Want git integration
- Multi-language projects
- Full IDE experience in terminal

**Use Vim (.vimrc):**
- Remote servers (SSH)
- Quick edits
- When Neovim isn't available
- Minimal resource usage
- Maximum portability

## Troubleshooting

### Plugins not installing
```bash
# Open Neovim and run:
:Lazy sync
```

### LSP not working
```bash
# Check LSP status:
:LspInfo

# Install language server manually:
:Mason
```

### Slow startup
```bash
# Profile startup time:
nvim --startuptime startup.log

# Check which plugins are slow in lazy.nvim:
:Lazy profile
```

### Reset to defaults
```bash
# Backup first:
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup

# Then re-symlink from dotfiles
```

## Customization

To add your own customizations:

1. **Add plugins**: Create new file in `lua/plugins/`
2. **Modify keybindings**: Edit `lua/core/keymaps.lua`
3. **Change options**: Edit `lua/core/options.lua`
4. **Add snippets**: Edit `lua/core/snippets.lua`

## Learning Resources

- `:Tutor` - Built-in Vim tutorial
- `:help` - Comprehensive help system
- `:help telescope` - Plugin-specific help
- `:checkhealth` - Verify Neovim setup
