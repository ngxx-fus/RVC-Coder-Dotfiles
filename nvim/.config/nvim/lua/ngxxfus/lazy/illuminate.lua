--- @file illuminate.lua
--- @brief Configuration for RRethy/vim-illuminate plugin.
--- @details Automatically highlights other uses of the word under the cursor.
--- @author ngxxfus
--- @date 2026-02-14

return {
  {
    --- @brief The illuminate plugin repository.
    "RRethy/vim-illuminate",

    --- @brief Load plugin when a buffer is read or a new file is created.
    event = { "BufReadPost", "BufNewFile" },

    --- @section Keymaps
    --- @brief Define keys to jump between references.
    keys = {
      { "<A-n>", function() require("illuminate").goto_next_reference(false) end, desc = "Next Reference" },
      { "<A-p>", function() require("illuminate").goto_prev_reference(false) end, desc = "Prev Reference" },
    },
    
    --- @brief Configuration function.
    config = function()
      require('illuminate').configure({
        providers = { 'regex', 'lsp', 'treesitter' },
        delay = 100,
        filetypes_denylist = {
          'dirbuf',
          'dirvish',
          'fugitive',
          'NvimTree',
          'neo-tree', -- Prevent dimming in the file explorer.
          'TelescopePrompt',
        },
        under_cursor = true,
        min_count_to_highlight = 1,
      })

      --- @brief Custom highlights: bold and italic without underline.
      --- @details We omit fg and bg to preserve syntax highlighting.
      local function custom_illuminate_colors()
        local hi = vim.api.nvim_set_hl
        -- Remove 'fg' and 'bg' to let the original syntax colors shine through.
        hi(0, "IlluminatedWordText",  { underline = false, bold = true, italic = true })
        hi(0, "IlluminatedWordRead",  { underline = false, bold = true, italic = true })
        hi(0, "IlluminatedWordWrite", { underline = false, bold = true, italic = true })
      end

      -- Execute immediately.
      custom_illuminate_colors()

      --- @brief Ensure styles persist after colorscheme changes.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = custom_illuminate_colors,
      })
    end,
  },
}
