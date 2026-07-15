-- Live, in-buffer markdown rendering -- nothing new opens.
--
-- Uses markview.nvim (not render-markdown) because it also renders INLINE markup that
-- render-markdown deliberately skips: **bold**, *italic*, `inline code`, ~~strike~~, as
-- well as fenced ```code blocks```, headings, tables, checkboxes, callouts, links, LaTeX.
--
-- Behaviour:
--   * NORMAL mode -> pure read mode: the whole buffer is rendered, including the cursor line.
--   * INSERT mode -> the line you're editing drops to raw markdown (hybrid), the rest stays
--     rendered. That's `hybrid_modes = { "i" }`.
return {
  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown", "markdown.mdx", "rmd", "quarto" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      -- Read view in NORMAL mode; INSERT mode shows raw markdown so you can edit, and markview
      -- re-renders automatically the instant you leave insert (<Esc> / jk). This is markview's
      -- reliable default -- forcing rendering *during* insert (the old hybrid config) is what
      -- left the view stale and un-refreshed.
      preview = {
        modes = { "n", "no", "c" }, -- render in normal / operator-pending / command modes
        hybrid_modes = {},          -- no per-line hybrid; the whole buffer is raw while editing
      },
    },
    keys = {
      { "<leader>um", "<cmd>Markview Toggle<cr>", desc = "Toggle Markdown render" },   -- key: Space u m
      { "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "Markdown split preview" }, -- key: Space m s
      -- Re-render markview AND force a full screen repaint. Use this if table/heading borders
      -- ever look broken or segmented (markview recomputes the marks; redraw! clears the stale
      -- screen cells that :Markview alone can't -- the same clean state a restart gives you).
      {
        "<leader>mr",
        function()
          pcall(vim.cmd, "Markview Render")
          vim.cmd("redraw!")
        end,
        desc = "Markdown re-render + redraw (fix borders)", -- key: Space m r
      },
    },
  },
}
