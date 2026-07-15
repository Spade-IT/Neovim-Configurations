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
      -- Read view in NORMAL mode. In INSERT mode the buffer STAYS rendered and only the line
      -- under the cursor drops to raw markdown -- so a table keeps its borders and columns
      -- while you edit one row, instead of the whole file collapsing to raw text.
      --
      -- Note: hybrid was disabled here once because tables "looked broken even after leaving
      -- insert". That was a misdiagnosis. The real cause was 'wrap' being on in markdown, which
      -- makes markview fall back to ASCII "-"/"|" borders (now fixed in config/autocmds.lua).
      -- Hybrid was never the problem.
      preview = {
        modes = { "n", "no", "c", "i" }, -- render in normal / op-pending / command / INSERT
        hybrid_modes = { "i" },          -- ...but in insert, un-render the cursor's line only
        -- Un-render the whole cursor LINE, not just the node under the cursor -- otherwise you
        -- get a half-rendered table row while typing in a cell.
        linewise_hybrid_mode = true,
      },

      markdown = {
        tables = {
          -- Draw a table's top/bottom borders as REAL virtual lines instead of markview's
          -- default, which hangs them off the neighbouring buffer line as inline virt_text
          -- (`virt_text_pos = "inline"` on range.row_start - 1). Neovim repaints those
          -- borrowed cells lazily, so corners stayed open until the cursor passed through
          -- them. Virtual lines own their row and always paint.
          --
          -- Cost: the border occupies a screen line above/below the table (it is not in the
          -- buffer, so nothing you edit or yank changes).
          use_virt_lines = true,
        },
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
