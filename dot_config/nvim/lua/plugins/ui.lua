-- colorscheme follows ~/.local/bin/theme
local state = vim.fn.expand("~/.local/state/theme")
local theme = vim.fn.filereadable(state) == 1 and vim.fn.readfile(state)[1] or "catppuccin"

return {
  { "navarasu/onedark.nvim", lazy = true, opts = { style = "darker" } },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, opts = { flavour = "mocha" } },
  { "LazyVim/LazyVim", opts = { colorscheme = theme == "onedark" and "onedark" or "catppuccin" } },

  -- keep the command line at the bottom, plain messages
  { "folke/noice.nvim", enabled = false },
}
