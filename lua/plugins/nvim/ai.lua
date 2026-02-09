return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    keys = {
      {
        "<leader>oa",
        function()
          require("opencode").ask("@this: ", { submit = true })
        end,
        mode = { "n", "x" },
        desc = "Opencode Ask",
      },
      {
        "<leader>ox",
        function()
          require("opencode").select()
        end,
        mode = { "n", "x" },
        desc = "Opencode Execute action",
      },
      {
        "<leader>to",
        function()
          require("opencode").toggle()
        end,
        mode = { "n", "t" },
        desc = "Toggle Opencode",
      },
      {
        "<leader>or",
        function()
          return require("opencode").operator "@this "
        end,
        mode = { "n", "x" },
        desc = "Opencode Add range",
        expr = true,
      },
      {
        "<leader>ol",
        function()
          return require("opencode").operator "@this " .. "_"
        end,
        desc = "Opencode Add line",
        expr = true,
      },
      {
        "<S-C-u>",
        function()
          require("opencode").command "session.half.page.up"
        end,
        desc = "Opencode Scroll up",
      },
      {
        "<S-C-d>",
        function()
          require("opencode").command "session.half.page.down"
        end,
        desc = "Opencode Scroll down",
      },
    },
    config = function()
      vim.g.opencode_opts = {
        provider = {
          enabled = "tmux",
          tmux = {
            options = "-h -l 30%",
          },
        },
      }
      vim.o.autoread = true
    end,
  },
}
