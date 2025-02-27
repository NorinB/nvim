local M = {}

M.filetypes = {
  bash = { "shfmt" },
  bib = { "texlab" },
  cs = { "csharpier" },
  dart = {},
  html = { "prettier" },
  htmlangular = { "prettier" },
  javascript = { "prettier" },
  json = { "prettier" },
  lua = { "stylua" },
  sh = { "shfmt" },
  -- tex = { "latexindent" },
  typescript = { "prettier" },
  yaml = { "yamlfmt" },
}

M.options = {
  formatters_by_ft = M.filetypes,
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { lsp_fallback = true }
  end,
}

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})

return M
