-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ─────────────────────────────────────────────────────────────────────────────
-- Markdown: 'wrap' OFF so markview draws real table borders
-- ─────────────────────────────────────────────────────────────────────────────
--
-- markview only draws box-drawing borders (╭─┬─╮ │ ├─┼─┤ ╰─┴─╯) when the window has
-- 'wrap' OFF. With wrap ON it takes a fallback path (`is_wrapped` in
-- markview/renderers/markdown.lua) that pads every separator row with literal "-" and
-- uses "|" -- which is why tables looked like |------|-----| instead of clean lines.
--
-- LazyVim sets wrap = false globally, but its `lazyvim_wrap_spell` FileType autocmd turns
-- it back ON for markdown/text/gitcommit. We re-disable it for markdown only, and leave
-- `spell` alone (that half of wrap_spell is still wanted).
--
-- Trade-off: long lines no longer soft-wrap in markdown -- they scroll horizontally. Our
-- docs are hard-wrapped at ~95 cols, so this is a non-issue here. Want wrapping back for a
-- specific buffer? `:set wrap` (tables in that buffer will drop to the ASCII look).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_nowrap_for_markview", { clear = true }),
  pattern = { "markdown", "markdown.mdx", "rmd", "quarto" },
  callback = function()
    vim.opt_local.wrap = false
  end,
})
