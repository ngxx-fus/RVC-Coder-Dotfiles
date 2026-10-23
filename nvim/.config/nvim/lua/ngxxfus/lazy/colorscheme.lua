--- @file colorscheme.lua
--- @brief Colorscheme configuration with Dark/Light mode toggle.
--- @author ngxxfus
--- @date 2026-02-06

--- @brief Toggle theme: 1 for Dark Mode, 0 for Light Mode.
local EnableDarkMode = 1 

return {
    {
        --- @brief VSCode theme plugin repository.
        "Mofiqul/vscode.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            --- @section Theme Setup
            --- @brief Initialize parameters based on EnableDarkMode flag.
            local theme_style = EnableDarkMode == 1 and "dark" or "light"
            local bg_mode = EnableDarkMode == 1 and "dark" or "light"
            local comment_fg = EnableDarkMode == 1 and "#6A9955" or "#008000"
            local file_fg = EnableDarkMode == 1 and "#D4D4D4" or "#333333"

            vim.o.background = bg_mode
            
            require('vscode').setup({
                style = theme_style,
                transparent = false,
                italic_comments = true,
                disable_nvimtree_bg = true,
                terminal_colors = true,
            })

            vim.cmd.colorscheme("vscode")

            --- @section UI Fixes
            --- @brief Force visibility for Neo-tree and disable Illuminate in sidebar.
            local function fix_ui_visibility()
                local highlights = {
                    ["NeoTreeFileName"]      = { fg = file_fg, bg = "NONE" },
                    ["NeoTreeDirectoryName"] = { fg = "#569CD6", bold = true },
                    ["NeoTreeGitUntracked"]  = { fg = file_fg },
                    ["NeoTreeRootName"]      = { fg = "#569CD6", bold = true },
                    ["NeoTreeGitIgnored"]    = { fg = "#666666", italic = true },
                    ["IlluminatedWordText"]  = { bg = "NONE" },
                    ["IlluminatedWordRead"]  = { bg = "NONE" },
                    ["IlluminatedWordWrite"] = { bg = "NONE" },
                }

                for group, settings in pairs(highlights) do
                    vim.api.nvim_set_hl(0, group, settings)
                end

                --- @brief Apply custom colors to comment groups.
                local comment_groups = { "Comment", "SpecialComment", "@comment", "@lsp.type.comment" }
                for _, group in ipairs(comment_groups) do
                    vim.api.nvim_set_hl(0, group, { fg = comment_fg, italic = true })
                end
            end

            fix_ui_visibility()

            --- @brief Ensure visibility is maintained across buffer/scheme changes.
            vim.api.nvim_create_autocmd({ "ColorScheme", "BufWinEnter" }, {
                callback = function()
                    if vim.bo.filetype == "neo-tree" then
                        fix_ui_visibility()
                    end
                end,
            })
            
            --- @section Cursor
            --- @brief Configure cursor appearance and visibility.
            vim.api.nvim_set_hl(0, "Cursor", { reverse = true })
            vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor"
        end,
    },
}
