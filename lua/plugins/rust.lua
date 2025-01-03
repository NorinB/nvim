return {
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    -- version = "^5",
    lazy = false,
    config = function()
      local lspconfig = require "configs.lsp"
      vim.g.rustaceanvim = {
        server = {
          autostart = true,
          on_attach = lspconfig.on_attach,
          capabilities = lspconfig.capabilities,
          on_init = lspconfig.on_init,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                features = "all",
                buildScripts = {
                  enable = true,
                },
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },
      }
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      local on_attach = require("configs.lsp").on_attach
      require("crates").setup {
        lsp = {
          enabled = true,
          on_attach = on_attach,
          actions = true,
          completion = true,
          hover = true,
        },
        completion = {
          insert_closing_quote = true,
          cmp = {
            enabled = true,
          },
          crates = {
            enabled = true,
          },
        },
      }

      local map = vim.keymap.set
      map("n", "<leader>rcu", function()
        require("crates").upgrade_all_crates()
      end, { desc = "Update Crates" })
      -- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
    end,
  },
}
