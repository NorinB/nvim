local get_status_text = function(self, opts)
  local multi_select_cnt = #(self:get_multi_selection())
  local showing_cnt = (self.stats.processed or 0) - (self.stats.filtered or 0)
  local total_cnt = self.stats.processed or 0

  local status_icon = ""
  local status_text
  if opts and not opts.completed then
    status_icon = "*"
  end

  if showing_cnt == 0 and total_cnt == 0 then
    status_text = status_icon
  elseif multi_select_cnt == 0 then
    status_text = string.format("%s %s / %s", status_icon, showing_cnt, total_cnt)
  else
    status_text = string.format("%s %s / %s / %s", status_icon, multi_select_cnt, showing_cnt, total_cnt)
  end

  local prompt_width = vim.api.nvim_win_get_width(self.prompt_win)
  local cursor_col = vim.api.nvim_win_get_cursor(self.prompt_win)[2]
  local prefix_display_width = require("plenary.strings").strdisplaywidth(self.prompt_prefix) --[[@as integer]]
  local prefix_width = #self.prompt_prefix
  local prefix_shift = 0
  if prefix_display_width ~= prefix_width then
    prefix_shift = prefix_display_width
  end

  local cursor_occluded = (prompt_width - cursor_col - #status_text + prefix_shift) < 0
  if cursor_occluded then
    return ""
  else
    return status_text
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      {
        "<leader>lda",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "Diagnostics All Diagnostics",
      },
      {
        "<leader>ldc",
        function()
          require("telescope.builtin").diagnostics { bufnr = 0 }
        end,
        desc = "Diagnostics Diagnostics Current Buf",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers {
            attach_mappings = function(_, map)
              map("n", "x", function(_prompt_bufnr)
                require("telescope.actions").delete_buffer(_prompt_bufnr)
              end, { desc = "Telescope Delete Buffer" })

              return true
            end,
          }
        end,
        desc = "Telescope Buffers",
      },
      { "<leader>fhe", "<cmd>Telescope help_tags<CR>", desc = "Telescope Help page" },
      {
        "<leader><leader>",
        function()
          local alt = vim.fn.expand "#"
          if alt ~= "" and vim.fn.filereadable(alt) == 1 then
            vim.cmd.edit(alt)
          else
            require("telescope.builtin").oldfiles { only_cwd = true }
          end
        end,
        desc = "Jump Last file or Telescope Oldfiles in cwd",
      },
      {
        "<leader>fo",
        function()
          require("telescope.builtin").oldfiles { only_cwd = true }
        end,
        desc = "Telescope Oldfiles in cwd",
      },
      { "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Telescope Current Buffer" },
      { "<leader>fgc", "<cmd>Telescope git_commits<CR>", desc = "Telescope Git commits" },
      { "<leader>fgt", "<cmd>Telescope git_status<CR>", desc = "Telescope Git status" },
      { "<leader>fgh", "<cmd>Telescope git_file_history<CR>", desc = "Telescope Git file history" },
      { "<leader>fte", "<cmd>Telescope terms<CR>", desc = "Telescope Terminals" },
      {
        "<leader>fa",
        "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
        desc = "Telescope Files (all)",
      },
      {
        '<leader>f"',
        function()
          require("telescope.builtin").registers()
        end,
        desc = "Telescope Registers",
      },
      { "<leader>fj", "<cmd>Telescope jumplist<CR>", desc = "Telescope Jumplist" },
      { "<leader>fco", "<cmd>Telescope commands<CR>", desc = "Telescope Commands" },
      { "<leader>fch", "<cmd>Telescope command_history<CR>", desc = "Telescope Command history" },
      { "<leader>fv", "<cmd>Telescope vim_options<CR>", desc = "Telescope Vim Options" },
      { "<leader>fsy", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Telescope Symbols" },
      { "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Telescope Resume last search" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Telescope Keybindings" },
      { "<leader>fma", "<cmd>Telescope marks<CR>", desc = "Telescope Marks" },
      { "<leader>fgs", "<cmd>Telescope grep_string<CR>", mode = { "n", "v" }, desc = "Telescope Grep String" },
      { "<leader>fsp", "<cmd>Telescope spell_suggest<CR>", desc = "Telescope Spell suggest" },
      { "<leader>fp", "<cmd>Telescope pickers<CR>", desc = "Telescope Pickers" },
      {
        "<leader>fz",
        function()
          local saved_reg = vim.fn.getreg "v"
          vim.cmd [[noautocmd sil norm! "vy]]
          local selection = vim.fn.getreg "v"
          vim.fn.setreg("v", saved_reg)
          if selection == nil then
            return nil
          end
          require("telescope.builtin").current_buffer_fuzzy_find {
            default_text = selection,
          }
        end,
        mode = { "v" },
        desc = "Telescope Current Buffer",
      },
      { "<leader>fhi", "<cmd>Telescope highlights<CR>", desc = "Telescope Highlights" },
    },
    opts = function()
      local function flash(prompt_bufnr)
        require("flash").jump {
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        }
      end

      return {
        pickers = {
          live_grep = {
            additional_args = { "--no-ignore", "--hidden" },
            file_ignore_patterns = {},
          },
          find_file = {
            hidden = false,
          },
        },
        defaults = {
          vimgrep_arguments = {
            "rg",
            "-L",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
          cache_picker = {
            num_pickers = 10,
            limit_entries = 1000,
            ignore_empty_prompt = false,
          },
          prompt_prefix = "   ",
          selection_caret = "> ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.4,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,
          file_ignore_patterns = { ".git", ".angular" },
          path_display = { "truncate", "filename_first" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
          buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
          mappings = {
            i = {
              ["<C-Down>"] = require("telescope.actions").preview_scrolling_down,
              ["<C-Up>"] = require("telescope.actions").preview_scrolling_up,
              ["<C-Left>"] = require("telescope.actions").preview_scrolling_left,
              ["<C-Right>"] = require("telescope.actions").preview_scrolling_right,
              ["<C-f>"] = flash,
            },
            n = {
              ["q"] = require("telescope.actions").close,
              m = flash,
              ["<C-Down>"] = require("telescope.actions").preview_scrolling_down,
              ["<C-Up>"] = require("telescope.actions").preview_scrolling_up,
              ["<C-Left>"] = require("telescope.actions").preview_scrolling_left,
              ["<C-Right>"] = require("telescope.actions").preview_scrolling_right,
            },
          },
        },
        extensions_list = {},
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {},
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require "telescope"
      telescope.setup(opts)
      for _, ext in ipairs(opts.extensions_list) do
        telescope.load_extension(ext)
      end

      require("colors").add_and_set_color_module("telescope", function()
        vim.api.nvim_set_hl(0, "TelescopeMatching", {
          fg = "#89b4fa",
          bg = "#76758a",
        })
        vim.api.nvim_set_hl(0, "TelescopeSelection", {
          fg = "#d9e0ee",
          bg = "#5c5a82",
        })
        vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", {
          fg = "#f2cdce",
          bg = "#5c5a82",
        })
        vim.api.nvim_set_hl(0, "TelescopePromptCounter", {
          fg = "#d9e0ee",
        })
        vim.api.nvim_set_hl(0, "TelescopeBorder", {
          fg = "#f9e2af",
        })
      end)
    end,
  },
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>fw", "<cmd>Telescope live_grep_args<CR>", desc = "Telescope Live grep" },
      {
        "<leader>fW",
        function()
          require("telescope").extensions.live_grep_args.live_grep_args {
            additional_args = { "--no-ignore", "--hidden" },
          }
        end,
        desc = "Telescope Live grep (all)",
      },
    },
    opts = function()
      local lga_actions = require "telescope-live-grep-args.actions"
      return {
        extensions = {
          live_grep_args = {
            file_ignore_patterns = {},
            auto_quoting = true,
            get_status_text = get_status_text,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-c>"] = lga_actions.quote_prompt { postfix = " -s " },
                ["<C-f>"] = lga_actions.quote_prompt { postfix = " -SF " },
                ["<C-i>"] = lga_actions.quote_prompt { postfix = " --iglob " },
                ["<C-space>"] = lga_actions.to_fuzzy_refine,
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension "live_grep_args"
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    config = function()
      require("telescope").load_extension "ui-select"
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    cmd = "TodoTelescope",
    keys = {
      { "<leader>fto", "<cmd>TodoTelescope<CR>", desc = "Telescope TODOs" },
    },
    config = function()
      require("todo-comments").setup()
    end,
  },
  {
    "isak102/telescope-git-file-history.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>fgi", "<cmd>Telescope git_file_history<CR>", desc = "Telescope Git file history" },
    },
    config = function()
      require("telescope").load_extension "git_file_history"
    end,
  },
  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        "<leader>ff",
        function()
          require("telescope").extensions.smart_open.smart_open {
            cwd_only = true,
            filename_first = true,
          }
        end,
        desc = "Telescope Files",
      },
    },
    config = function()
      local telescope = require "telescope"
      telescope.setup {
        extensions = {
          smart_open = {
            result_limit = 40,
            get_status_text = get_status_text,
          },
        },
      }
      telescope.load_extension "smart_open"
    end,
  },
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
    event = "LspAttach",
    config = function()
      require("telescope").load_extension "dap"
    end,
  },
}
