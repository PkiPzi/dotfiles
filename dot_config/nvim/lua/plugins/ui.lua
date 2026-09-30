return {
  -- One Dark to match alacritty
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "darker" },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "onedark" } },

  -- keep the command line at the bottom, plain messages
  { "folke/noice.nvim", enabled = false },
}
