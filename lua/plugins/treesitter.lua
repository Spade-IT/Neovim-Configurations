-- Extra Treesitter parsers.
-- `latex` is required by snacks.image to render LaTeX math expressions.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "latex" } },
  },
}
