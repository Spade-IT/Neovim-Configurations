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

**The renderer is the spec, not a linter.** These docs are read inside Neovim via
**markview.nvim**. `lang.markdown` is deliberately disabled, so `markdownlint` is
*not* part of this setup — do not add it back or "fix" docs to satisfy it.

**Never run `markdownlint --fix` on these files.** It is not safe and has already
corrupted this README once:

- It rewrote every table's delimiter row from compact (`|-----|`) to spaced
  (`| ----- |`) — markview renders from those rows.
- Its MD038 "fix" stripped the spaces out of `` `` <leader>`` `` , silently
  deleting the literal backtick and documenting **the wrong keybinding**.

If you touch a doc, judge it by whether markview renders it, not by a lint score.

Real invariants (these actually break rendering):

- **A table needs a blank line before it** or it renders as literal text. This is
  the single most common breakage here.
- **Every table row needs a leading *and* trailing pipe.** A missing leading pipe
  silently breaks the whole table.
- **A literal pipe inside a cell must be escaped `\|`** (e.g. `` `<leader>\|` ``).
- **Avoid backticks inside table cells that wrap other backticks** — it breaks
  markview's column-width calculation. Spell it out ("backtick-backtick") instead.
- A heading wants a blank line after it; a list wants blank lines around it.

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
  when avoidable. Three are off *on purpose* — re-enabling them breaks things:
  - `editor.neo-tree` / `editor.telescope` **replace** snacks.explorer and
    snacks.picker, invalidating the documented explorer keys.
  - `lang.markdown` ships `markdownlint-cli2` **and** `render-markdown.nvim`,
    which duplicates and fights markview.nvim.
- There has never been a "no extras" commit — `lazyvim.json` has had extras since
  the initial commit. Don't go looking for one to revert to.
- `lazy-lock.json` and `lazyvim.json` get rewritten by Neovim on its own. Don't
  sweep that churn into an unrelated commit; keep commits focused.
- Line endings are governed by `.gitattributes` (`.sh` = LF, `.ps1` = CRLF). The
  "LF will be replaced by CRLF" warning on commit is expected on Windows.
- Arrow keys are **deliberately disabled** in normal/insert mode, and the "cowboy"
  nags on mashed `hjkl`. These are intentional discipline features, not bugs.
