-- with the solstice rice on, let alacritty's translucent background show through
local state = vim.fn.expand("~/.local/state/rice")
local rice = vim.fn.filereadable(state) == 1 and vim.fn.readfile(state)[1] or "plain"

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",
      transparent_background = rice == "solstice",
      float = { transparent = false, solid = false },
    },
  },
  -- "catppuccin-mocha", not "catppuccin": nvim 0.12 ships its own catppuccin.vim that ignores these opts
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin-mocha" } },

  -- keep the command line at the bottom, plain messages
  { "folke/noice.nvim", enabled = false },
}
