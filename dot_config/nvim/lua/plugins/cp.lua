-- competitive programming: receive problems from the Competitive Companion
-- browser extension, run all testcases, compare outputs
local flags = { "-std=c++20", "-O2", "-Wall", "-Wextra", "-DLOCAL" }

return {
  {
    "xeluxee/competitest.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    cmd = "CompetiTest",
    keys = {
      { "<leader>r", "", desc = "+competitest" },
      { "<leader>rr", "<cmd>CompetiTest run<cr>", desc = "Run testcases" },
      { "<leader>rs", "<cmd>CompetiTest show_ui<cr>", desc = "Show results" },
      { "<leader>ra", "<cmd>CompetiTest add_testcase<cr>", desc = "Add testcase" },
      { "<leader>re", "<cmd>CompetiTest edit_testcase<cr>", desc = "Edit testcase" },
      { "<leader>rd", "<cmd>CompetiTest delete_testcase<cr>", desc = "Delete testcase" },
      { "<leader>rp", "<cmd>CompetiTest receive problem<cr>", desc = "Receive problem" },
      { "<leader>rc", "<cmd>CompetiTest receive contest<cr>", desc = "Receive contest" },
      { "<leader>rt", "<cmd>CompetiTest receive testcases<cr>", desc = "Receive testcases" },
    },
    opts = {
      compile_command = {
        cpp = { exec = "g++", args = vim.list_extend(vim.deepcopy(flags), { "$(FNAME)", "-o", "$(FNOEXT)" }) },
      },
      run_command = { cpp = { exec = "./$(FNOEXT)" } },
      maximum_time = 2000,
      testcases_use_single_file = true,
      template_file = { cpp = "~/cp/template.cpp" },
      received_problems_path = "$(HOME)/cp/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)",
      received_problems_prompt_path = false,
      received_contests_directory = "$(HOME)/cp/$(JUDGE)/$(CONTEST)",
      received_contests_prompt_directory = false,
      received_contests_prompt_extension = false,
    },
  },
}
