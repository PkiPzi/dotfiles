local function dsa(cmd) return "<cmd>w | botright 15split | terminal dsa " .. cmd .. "<cr>" end
vim.keymap.set("n", "<leader>dr", dsa("run"),    { desc = "dsa run" })
vim.keymap.set("n", "<leader>ds", dsa("submit"), { desc = "dsa submit" })
vim.keymap.set("n", "<leader>dd", dsa("debug"),  { desc = "dsa debug" })
vim.keymap.set("n", "<leader>dw", dsa("watch"),  { desc = "dsa watch" })
