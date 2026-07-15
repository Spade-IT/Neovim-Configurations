# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

A personal **LazyVim**-based Neovim config, primarily developed on **Windows**
(`%LOCALAPPDATA%\nvim`) but intended to work unchanged on macOS/Linux
(`~/.config/nvim`). It is the live config directory *and* a git repo — edits here
take effect the next time Neovim starts.

Repo: <https://github.com/Spade-IT/Neovim-Configurations> (`origin`, branch `main`).
Plugin/parser/mason data lives **outside** the repo in `nvim-data/` and is not tracked.

## Layout & where things go

```text
init.lua                 entry point: require("config.lazy")
lua/config/lazy.lua      lazy.nvim bootstrap + LazyVim spec (rocks disabled)
lua/config/options.lua   editor options (currently LazyVim defaults only)
lua/config/autocmds.lua  autocommands (currently LazyVim defaults only)
lua/config/keymaps.lua   ★ ALL custom keymaps, user commands, dashboard logic
lua/config/discipline.lua ★ the "cowboy" habit trainer
lua/plugins/*.lua        one file per plugin override; each returns a lazy.nvim spec
setup/                   cross-OS installers: nvim-setup.ps1 / nvim-setup.sh
lazy-lock.json           plugin version lockfile (tracked)
lazyvim.json             which LazyVim extras are enabled (tracked)
```

- **New custom keymap / user command → `lua/config/keymaps.lua`.** It uses
  `local map = vim.keymap.set` and every map carries a `desc`.
- **New or overridden plugin → a file in `lua/plugins/`.** Your specs merge on top
  of LazyVim and **win on conflicts**.
- `lua/plugins/example.lua` is inert (`if true then return {} end`) — leave it.

## Non-negotiable: README.md is the source of truth for keybindings

`README.md` is a complete reference (options, plugins, discipline system, and a
full keybinding table covering Vim/Neovim/LazyVim defaults *plus* customs).

- **Any keymap change must be reflected in the README's section 7 table** in the
  same commit. Mark custom additions with **★**.
- Before claiming a key is "unlisted", check the README — most defaults are
  already documented, including the in-explorer snacks keys.
- Keys can appear "dead" due to context (needs ≥2 buffers, an LSP, a git repo…).
  The README has a **Conditions** subsection for exactly this — add to it rather
  than treating a context-dependent key as broken.

## Markdown rules (this bites every time)

The repo is **markdownlint-clean**; config in `.markdownlint.json`
(line_length 100; `tables` and `code_blocks` exempt because table rows and the
ASCII tree physically cannot be wrapped). Verify with:

```bash
npx --yes markdownlint-cli README.md      # must print nothing
npx --yes markdownlint-cli --fix README.md  # auto-fixes pipes/spacing safely
```

Hard-won gotchas:

- **A table needs a blank line before it** or it renders as literal text. This is
  the single most common breakage here.
- **A heading needs a blank line after it** (MD022), and a list needs blank lines
  around it (MD032).
- **Every table row needs a leading *and* trailing pipe.** A missing leading pipe
  silently breaks the table (MD055 catches it).
- **Avoid backticks inside table cells that wrap other backticks** — it breaks
  markview's column-width calculation. Spell it out ("backtick-backtick") instead.

## Verifying changes

Neovim behavior must be verified **headlessly**, and the dashboard interleaves
with stdout — so **write results to a file and read that back**, don't parse stdout:

```bash
nvim --headless -c 'lua <checks>' -c 'qa' # write findings to a temp file, then read it
```

Trigger lazy-loaded plugins first with
`vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })` + a `vim.wait(...)`.

## Things to be careful with

- **Do not run `:Lazy clean` / delete `nvim-data/` without being asked** — it
  destroys installed plugins.
- **Extras** (`lazyvim.json`) are enabled via `:LazyExtras`, not by hand-editing
  when avoidable. Note `editor.neo-tree` and `editor.telescope` **replace**
  snacks.explorer/snacks.picker and would invalidate the documented explorer keys.
- `lazy-lock.json` and `lazyvim.json` get rewritten by Neovim on its own. Don't
  sweep that churn into an unrelated commit; keep commits focused.
- Line endings are governed by `.gitattributes` (`.sh` = LF, `.ps1` = CRLF). The
  "LF will be replaced by CRLF" warning on commit is expected on Windows.
- Arrow keys are **deliberately disabled** in normal/insert mode, and the "cowboy"
  nags on mashed `hjkl`. These are intentional discipline features, not bugs.
