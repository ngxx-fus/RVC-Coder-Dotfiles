--- @file set.lua
--- @brief Neovim editor settings and options configuration.
--- @details Configures global options for interface, indentation, and behavior.
--- @author ngxxfus
--- @date 2025-11-30

--- @brief Uncomment to use tokyonight colorscheme.
-- vim.cmd.colorscheme("tokyonight")

--- @brief Enable 24-bit RGB color in the terminal.
vim.opt.termguicolors = true

--- @brief Enable line numbers.
vim.opt.nu = true

--- @brief Show relative line numbers.
vim.opt.relativenumber = false -- true

--- @brief Sync with system clipboard (requires xclip or similar).
vim.opt.clipboard = 'unnamedplus'

--- @brief Number of spaces that a <Tab> in the file counts for.
vim.opt.tabstop = 4

--- @brief Number of spaces that a <Tab> counts for while editing.
vim.opt.softtabstop = 4

--- @brief Number of spaces to use for each step of (auto)indent.
vim.opt.shiftwidth = 4

--- @brief Use spaces instead of tabs.
vim.opt.expandtab = true

--- @brief Do smart autoindenting when starting a new line.
vim.opt.smartindent = true

--- @brief Disable line wrapping.
vim.opt.wrap = false

--- @brief Show search matches as you type.
vim.opt.incsearch = true

vim.opt.termguicolors = true

--- @brief Enable horizontal scroll using Alt + Mouse Wheel for all common modes
--- @details Maps Alt + Wheel to scroll 5 characters left/right. Supports Normal, Visual, and Select.
local scroll_modes = { 'n', 'v', 's', 'x' }
for _, mode in ipairs(scroll_modes) do
    vim.keymap.set(mode, '<M-ScrollWheelUp>', '5zh', { desc = 'Scroll left' })
    vim.keymap.set(mode, '<M-ScrollWheelDown>', '5zl', { desc = 'Scroll right' })
end

--- @brief Horizontal scroll for Insert mode without leaving insert state
--- @details Uses <C-o> to execute normal mode commands temporarily
vim.keymap.set('i', '<M-ScrollWheelUp>', '<C-o>5zh', { desc = 'Scroll left (Insert)' })
vim.keymap.set('i', '<M-ScrollWheelDown>', '<C-o>5zl', { desc = 'Scroll right (Insert)' })
