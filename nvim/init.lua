-- ========================================
-- Simple Neovim Configuration
-- ========================================
-- This is a minimal, easy-to-understand config.
-- Add more features as you learn!

-- ========================================
-- Basic Options
-- ========================================

-- Line numbers
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Show relative line numbers

-- Search
vim.opt.ignorecase = true          -- Case-insensitive search
vim.opt.smartcase = true           -- But case-sensitive if search has capitals
vim.opt.hlsearch = false           -- Don't highlight all search results

-- Editing
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.shiftwidth = 4             -- Number of spaces for indentation
vim.opt.tabstop = 4                -- Number of spaces for tab
vim.opt.smartindent = true         -- Auto-indent new lines

-- UI
vim.opt.scrolloff = 8              -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8          -- Keep 8 columns left/right of cursor
vim.opt.signcolumn = "yes"         -- Always show sign column (for git, etc)
vim.opt.cursorline = false         -- Don't highlight current line
vim.opt.wrap = false               -- Don't wrap long lines
vim.opt.splitbelow = true          -- Horizontal splits go below
vim.opt.splitright = true          -- Vertical splits go right

-- Files
vim.opt.swapfile = false           -- Don't create swap files
vim.opt.backup = false             -- Don't create backup files
vim.opt.undofile = true            -- Save undo history
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard

-- Misc
vim.opt.mouse = "a"                -- Enable mouse
vim.opt.termguicolors = true       -- Enable 24-bit colors
vim.opt.updatetime = 250           -- Faster completion


-- ========================================
-- Keybindings
-- ========================================

-- Set leader key to Space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable space in normal/visual mode (since it's our leader)
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Window management
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>h", "<C-w>s", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal" })
vim.keymap.set("n", "<leader>xs", ":close<CR>", { desc = "Close split" })

-- Buffer navigation
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>b", ":enew<CR>", { desc = "New buffer" })

-- Save and quit
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<C-q>", ":q<CR>", { desc = "Quit" })

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search" })

-- Better scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")  -- Scroll down and center
vim.keymap.set("n", "<C-u>", "<C-u>zz")  -- Scroll up and center
vim.keymap.set("n", "n", "nzzzv")         -- Next search result and center
vim.keymap.set("n", "N", "Nzzzv")         -- Previous search result and center

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Quick escape from insert mode
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")

-- Delete without copying to clipboard
vim.keymap.set("n", "x", '"_x')

-- Copy to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Copy line to clipboard" })


-- ========================================
-- Plugin Manager (lazy.nvim)
-- ========================================
-- We need this to install the Catppuccin theme

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- Install lazy.nvim if it's not already installed
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Install plugins
require("lazy").setup({
  -- Catppuccin color scheme
  -- Docs: https://github.com/catppuccin/nvim
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Load this first
    config = function()
      -- Optional: Customize the theme
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = false,
      })

      -- Apply the color scheme
      vim.cmd.colorscheme("catppuccin")
    end,
  },
})


-- ========================================
-- Color Scheme
-- ========================================
-- Catppuccin is now loaded!
-- You can change the flavor in the config above:
--   - latte (light theme)
--   - frappe (dark with blue tones)
--   - macchiato (darker)
--   - mocha (darkest - default)


-- ========================================
-- File Explorer (built-in Netrw)
-- ========================================

-- Configure the built-in file explorer
vim.g.netrw_banner = 0        -- Hide banner
vim.g.netrw_liststyle = 3     -- Tree view
vim.g.netrw_browse_split = 4  -- Open in previous window
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25      -- 25% width

-- Toggle file explorer
vim.keymap.set("n", "<leader>e", ":Lex<CR>", { desc = "Toggle file explorer" })


-- ========================================
-- That's it! Simple and functional.
-- ========================================
-- Want to add more features? Check out:
-- - nvim-complex-backup/ for the full config
-- - :help for Neovim docs
-- - YouTube: "Neovim from scratch" tutorials
