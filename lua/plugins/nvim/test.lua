return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Language specifics
      "NorinB/neotest-dart",
      "nvim-neotest/neotest-jest",
      "weilbith/neotest-gradle",
      "Issafalcon/neotest-dotnet",
    },
    cmd = "Neotest summary",
    event = { "BufEnter *spec*", "BufEnter *test*" },
    keys = {
      {
        "<leader>Td",
        function()
          require("neotest").run.run { strategy = "dap" }
        end,
        desc = "Test Debug nearest",
      },
      {
        "<leader>Tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Test Run nearest",
      },
      {
        "<leader>TR",
        function()
          require("neotest").run.run(vim.fn.expand "%")
        end,
        desc = "Test Run file",
      },
      {
        "<leader>TD",
        function()
          require("neotest").run.run { vim.fn.expand "%", strategy = "dap" }
        end,
        desc = "Test Debug file",
      },
      {
        "<leader>TS",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test Toggle summary",
      },
      {
        "<leader>To",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Test Toggle output",
      },
      {
        "<leader>Tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Test Run last",
      },
      {
        "<leader>TL",
        function()
          require("neotest").run.run_last { strategy = "dap" }
        end,
        desc = "Test Debug last",
      },
      {
        "<leader>Ts",
        function()
          require("neotest").run.stop()
        end,
        desc = "Test Stop",
      },
    },
    opts = function()
      return {
        adapters = {
          require "neotest-dart" {
            command = "fvm flutter",
            use_lsp = true,
            custom_test_method_names = { "blocTest" },
            additional_args = { "--no-pub" },
          },
          require "neotest-gradle",
          require "neotest-jest" {
            cwd = function()
              return vim.fn.getcwd()
            end,
            jestConfigFile = function(file_path)
              if string.match(file_path, "e2e") ~= nil then
                local start_dir = vim.fn.fnamemodify(file_path, ":h")
                local matches = vim.fs.find(function(name, path)
                  local lname = name:lower()
                  return lname:find "jest" ~= nil and lname:find "e2e" ~= nil
                end, {
                  path = start_dir,
                  upward = true,
                  type = "file",
                  limit = math.huge,
                  stop = vim.fn.fnamemodify(vim.fn.getcwd(), ":h"),
                })
                if #matches > 0 then
                  return matches[#matches]
                end
              end
              return nil
            end,
            jestCommand = function(file_path)
              if string.match(file_path, "e2e") ~= nil then
                return "npx jest"
              end
              return "npx jest"
            end,
          },
          require "neotest-dotnet" {
            dap = {
              adapter_name = "coreclr",
            },
          },
        },
      }
    end,
  },
}
