return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "User FilePost",
    opts = {
      indent = { char = "│", highlight = "IblChar" },
      scope = { char = "│", highlight = "IblScopeChar" },
    },
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "blankline")
      local hooks = require "ibl.hooks"

      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      require("ibl").setup(opts)

      dofile(vim.g.base46_cache .. "blankline")
    end,
  },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "comment toggle current line" },
      { "gc", mode = { "n", "o" }, desc = "comment toggle linewise" },
      { "gc", mode = "x", desc = "comment toggle linewise (visual)" },
      { "gbc", mode = "n", desc = "comment toggle current block" },
      { "gb", mode = { "n", "o" }, desc = "comment toggle blockwise" },
      { "gb", mode = "x", desc = "comment toggle blockwise (visual)" },
    },
    config = function(_, opts)
      require("Comment").setup(opts)
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- Defaults
      enable_close = true, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = true, -- Auto close on trailing </
    },
    config = function(_, opts)
      require("nvim-ts-autotag").setup {
        opts = opts,
      }
    end,
  },
  {
    "tzachar/highlight-undo.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      return require "configs.highlight-undo"
    end,
    config = function(_, opts)
      require("highlight-undo").setup(opts)
    end,
  },
  {
    "rmagatti/goto-preview",
    config = function()
      require("goto-preview").setup()
    end,
  },
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle" },
  },
  {
    "tpope/vim-surround",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "folke/zen-mode.nvim",
    cmd = { "ZenMode" },
  },
}