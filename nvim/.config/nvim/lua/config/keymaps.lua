-- ===========================================================================
-- keymaps.lua - Core Neovim keymaps
-- ===========================================================================

local map = vim.keymap.set

-- Leader key
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ---------------------------------------------------------------------------
-- Normal mode
-- ---------------------------------------------------------------------------
-- Save / Quit
map("n", "<leader>w", "<cmd>w<CR>",          { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>",          { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>",        { desc = "Force quit all" })

-- Move between windows
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })

-- Resize windows
map("n", "<C-Up>",    "<cmd>resize +2<CR>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<CR>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>",     { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- ---------------------------------------------------------------------------
-- Visual mode
-- ---------------------------------------------------------------------------
-- Stay in indent mode
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move selected lines
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ---------------------------------------------------------------------------
-- Insert mode
-- ---------------------------------------------------------------------------
-- Exit insert mode quickly
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })