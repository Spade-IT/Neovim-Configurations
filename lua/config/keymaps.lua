-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- ─────────────────────────────────────────────────────────────────────────────
-- Discipline (the "cowboy") -- build good movement habits.
-- ─────────────────────────────────────────────────────────────────────────────

-- Nag when h / j / k / l / + / - are mashed >10x in a row (see config/discipline.lua).
require("config.discipline").cowboy()

-- Disable the arrow keys everywhere (pure-Vim, no Windows-style remaps). In normal mode use
-- hjkl + motions; in insert mode use the NATIVE Vim keys -- Ctrl-w / Ctrl-u to delete, and
-- <Esc> or jk back to normal mode for anything more than a couple of characters.
-- (Want arrows back in insert as a fallback? change map({ "n", "i" }, ...) to map("n", ...).)
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  map({ "n", "i" }, key, function()
    vim.notify("Use hjkl / motions -- arrow keys are disabled.", vim.log.levels.WARN, { title = "Discipline" })
  end, { desc = "Arrow disabled (use hjkl / motions)" })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Insert-mode escape
-- ─────────────────────────────────────────────────────────────────────────────
map("i", "jk", "<Esc>", { desc = "jk -> leave insert mode (Esc)" }) -- key: j then k
map("i", "jj", "<Esc>", { desc = "jj -> leave insert mode (Esc)" }) -- key: j then j

-- ─────────────────────────────────────────────────────────────────────────────
-- Navigation -- keep the cursor centered so you never lose your place
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<C-d>", "<C-d>zz", { desc = "Ctrl-d -> half page down, centered" })  -- key: Ctrl+d
map("n", "<C-u>", "<C-u>zz", { desc = "Ctrl-u -> half page up, centered" })    -- key: Ctrl+u
map("n", "n", "nzzzv", { desc = "n -> next search match, centered" })          -- key: n
map("n", "N", "Nzzzv", { desc = "N -> previous search match, centered" })      -- key: Shift+n

-- Screen-position motions ("go High / Middle / Low"). LazyVim remaps H/L to Prev/Next Buffer,
-- so the classic cursor-to-top/middle/bottom-of-screen motions live on these g-prefixed keys.
-- (`noremap` targets Vim's built-in H/M/L, not LazyVim's buffer maps. Buffer nav stays on H/L.)
map("n", "gh", "H", { desc = "gh -> cursor to top of visible screen (High)" })    -- key: g then h
map("n", "gm", "M", { desc = "gm -> cursor to middle of visible screen" })         -- key: g then m
map("n", "gl", "L", { desc = "gl -> cursor to bottom of visible screen (Low)" })   -- key: g then l

-- ─────────────────────────────────────────────────────────────────────────────
-- Editing
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "J", "mzJ`z", { desc = "J -> join line below, keep cursor put" })     -- key: Shift+j (normal)
map("x", "J", ":m '>+1<CR>gv=gv", { desc = "J -> move selection down" })        -- key: Shift+j (visual)
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "K -> move selection up" })          -- key: Shift+k (visual)
map("x", "<", "<gv", { desc = "< -> indent left, keep selection" })            -- key: < (visual)
map("x", ">", ">gv", { desc = "> -> indent right, keep selection" })           -- key: > (visual)
map("x", "p", [["_dP]], { desc = "p -> paste over selection without losing yank" }) -- key: p (visual)

-- ─────────────────────────────────────────────────────────────────────────────
-- System clipboard (leader = space). These keys are free in LazyVim.
-- ─────────────────────────────────────────────────────────────────────────────
map({ "n", "x" }, "<leader>y", [["+y]], { desc = "<leader>y -> yank to system clipboard" })  -- key: Space y
map("n", "<leader>Y", [["+Y]], { desc = "<leader>Y -> yank whole line to system clipboard" }) -- key: Space Y
map({ "n", "x" }, "<leader>P", [["+p]], { desc = "<leader>P -> paste from system clipboard" }) -- key: Space P

-- ─────────────────────────────────────────────────────────────────────────────
-- Misc
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Esc -> clear search highlight" }) -- key: Esc
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Ctrl-s -> save file" })                    -- key: Ctrl+s

-- ─────────────────────────────────────────────────────────────────────────────
-- Cherry-picked from jdhao/nvim-config (LazyVim already does auto-mkdir-on-save
-- and restore-last-cursor, so those are intentionally NOT re-added here).
-- ─────────────────────────────────────────────────────────────────────────────

-- gV -> reselect the text you just pasted or yanked.
map("n", "gV", "`[v`]", { desc = "gV -> reselect last pasted/changed text" }) -- key: g then V

-- :TrimWhitespace -> strip trailing whitespace across the file (cursor kept).
vim.api.nvim_create_user_command("TrimWhitespace", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end, { desc = "Remove trailing whitespace" })

-- :Cd -> change Neovim's working directory to the current file's folder.
vim.api.nvim_create_user_command("Cd", function()
  vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.expand("%:p:h")))
  vim.notify("cwd -> " .. vim.fn.getcwd())
end, { desc = "cd to current file's directory" })

-- ─────────────────────────────────────────────────────────────────────────────
-- Home / dashboard -- the LazyVim start screen (snacks.dashboard) is your "homepage"
-- ─────────────────────────────────────────────────────────────────────────────

-- How many real, NAMED file buffers are still open (dashboard / scratch / help don't count).
local function files_open()
  local n = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].buflisted
      and vim.bo[b].buftype == ""
      and vim.api.nvim_buf_get_name(b) ~= ""
    then
      n = n + 1
    end
  end
  return n
end

local function go_home()
  if vim.bo.filetype == "snacks_dashboard" then
    return -- already home; don't stack another dashboard
  end
  pcall(function()
    Snacks.dashboard.open()
  end)
end

-- :Home  -> close every open file and drop back to the dashboard (stays in Neovim).
-- Unsaved buffers are kept (their delete safely fails), so you never lose work.
vim.api.nvim_create_user_command("Home", function()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted and vim.bo[b].buftype == "" then
      pcall(vim.api.nvim_buf_delete, b, { force = false })
    end
  end
  vim.schedule(go_home)
end, { desc = "Close all files and go to the dashboard (homepage)" })

-- :Quit  -> close all files and exit Neovim (like :qa). Add ! to force past unsaved changes.
vim.api.nvim_create_user_command("Quit", function(o)
  vim.cmd(o.bang and "qa!" or "qa")
end, { bang = true, desc = "Quit Neovim (close all files + close the editor)" })

map("n", "<leader>H", "<cmd>Home<cr>", { desc = "<leader>H -> home (close files -> dashboard)" }) -- key: Space H

-- Auto: closing the LAST open file returns you to the dashboard. BufDelete fires on :bd /
-- <leader>bd but NOT on :qa, so this never blocks quitting Neovim.
vim.api.nvim_create_autocmd("BufDelete", {
  group = vim.api.nvim_create_augroup("home_on_last_file", { clear = true }),
  callback = function()
    vim.schedule(function()
      if files_open() == 0 and package.loaded["snacks"] then
        go_home()
      end
    end)
  end,
})
