-- ===========================================================================
-- options.lua - Core Neovim options
-- ===========================================================================

local opt = vim.opt

-- UI
opt.number         = true       -- Show line numbers
opt.relativenumber = true       -- Relative line numbers
opt.cursorline     = true       -- Highlight current line
opt.signcolumn     = "yes"      -- Always show sign column
opt.scrolloff      = 8          -- Lines of context
opt.wrap           = false      -- No line wrap
opt.termguicolors  = true       -- True color support

-- Indentation
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true
opt.smartindent    = true

-- Search
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = false
opt.incsearch      = true

-- Files
opt.swapfile       = false
opt.backup         = false
opt.undofile       = true
opt.undodir        = os.getenv("HOME") .. "/.vim/undodir"

-- Performance
opt.updatetime     = 50
opt.timeoutlen     = 300

-- Clipboard
opt.clipboard      = "unnamedplus"

-- Split
opt.splitright     = true
opt.splitbelow     = true