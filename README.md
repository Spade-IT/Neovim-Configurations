# Neovim Config

A personal [LazyVim](https://github.com/LazyVim/LazyVim)-based Neovim setup for Windows.
This README is a **complete reference**: how the config is structured, how to build a LazyVim
setup from scratch, every option and plugin, the **discipline system**, and a full
**keybinding reference** covering Vim / Neovim / LazyVim defaults *plus* everything we added.

> Base: LazyVim (no extras enabled). Anything marked **★ custom** is added on top.

---

## Table of contents
1. [Directory layout](#1-directory-layout)
2. [LazyVim from scratch (no starter repo)](#2-lazyvim-from-scratch-no-starter-repo)
3. [External tools & language providers](#3-external-tools--language-providers)
4. [Options / settings](#4-options--settings)
5. [Plugins](#5-plugins)
6. [The discipline system](#6-the-discipline-system)
7. [Keybinding reference](#7-keybinding-reference)
8. [User commands](#8-user-commands)
9. [Launching, maintenance & health](#9-launching-maintenance--health)

Notation: `<leader>` = `Space` · `<C-x>` = `Ctrl+x` · `<S-x>` = `Shift+x` · `<M-x>` = `Alt+x` ·
`<CR>` = Enter · `<BS>` = Backspace. In insert mode `hjkl` type letters, so movement there is
via the native keys in section 7.

---

## 1. Directory layout

```Folder
~/AppData/Local/nvim/               (== stdpath("config"))
├── init.lua                        entry point: require("config.lazy")
├── lua/
│   ├── config/
│   │   ├── lazy.lua                lazy.nvim bootstrap + options (luarocks disabled)
│   │   ├── options.lua             editor options (LazyVim defaults only)
│   │   ├── autocmds.lua            autocommands (LazyVim defaults only)
│   │   ├── keymaps.lua             ★ custom keymaps + discipline + commands
│   │   └── discipline.lua          ★ the "cowboy" habit trainer
│   └── plugins/
│       ├── markdown.lua            ★ markview.nvim (in-TUI live markdown render)
│       ├── treesitter.lua          ★ extra parser: latex
│       └── example.lua             LazyVim examples (inactive: `if true then return {} end`)
├── setup/                          ★ install scripts: nvim-setup.ps1 (Windows) / .sh (macOS/Linux)
├── lazy-lock.json                  plugin version lockfile
└── lazyvim.json                    which LazyVim "extras" are enabled (none right now)
```

Data (plugins, parsers, mason) lives in `~/AppData/Local/nvim-data/`.

---

## 2. LazyVim from scratch (no starter repo)

You don't need to clone `LazyVim/starter`. LazyVim is a plugin you bootstrap with `lazy.nvim`.

**a. Locations (Windows):** config at `%LOCALAPPDATA%\nvim`, data at `%LOCALAPPDATA%\nvim-data`.
Back up/remove any existing ones first.

**b. `init.lua`** — the only file Neovim loads on startup:

```lua
require("config.lazy")
```

**c. `lua/config/lazy.lua`** — bootstrap lazy.nvim, then hand it the LazyVim spec:

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" }, -- all of LazyVim
    { import = "plugins" },                            -- your own lua/plugins/*.lua
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  rocks = { enabled = false },   -- skip luarocks (nothing here needs it)
  checker = { enabled = true, notify = false },
})
```

**d. `lua/config/options.lua` / `keymaps.lua` / `autocmds.lua`** — optional, auto-loaded by
LazyVim (options before startup; keymaps/autocmds on the `VeryLazy` event). Can be empty.

**e. `lua/plugins/*.lua`** — each returns a lazy.nvim spec (a table). Add/override plugins here:

```lua
return {
  { "owner/plugin.nvim", opts = { ... } },
}
```

**f. First launch:** open `nvim`; lazy.nvim clones LazyVim + all plugins automatically. Then
run `:checkhealth`.

**How the pieces fit:** `lazy.nvim` = plugin manager · `LazyVim/LazyVim` = a curated spec of
plugins + config + keymaps · your `import = "plugins"` merges on top and **wins on conflicts**.
**Extras** (language packs etc.) are opt-in via `:LazyExtras`, recorded in `lazyvim.json`.

---

## 3. External tools & language providers

Installer scripts live in `setup/` — `nvim-setup.ps1` (Windows) and `nvim-setup.sh` (macOS/Linux).

- `git`, `curl`, `tar` — plugin/parser downloads, lazygit
- `ripgrep` (rg), `fd` — file & text search (snacks.picker)
- `fzf` — fuzzy finder
- `lazygit` — git UI (`<leader>gg`)
- `tree-sitter` CLI + C compiler — building treesitter parsers
- `ast-grep` (sg) — structural search (grug-far)
- `ImageMagick`, `Ghostscript` (gs), `Tectonic`, `mmdc` — snacks.image: image / PDF / LaTeX / Mermaid tooling
- `win32yank` — system clipboard

> Displaying image previews in-terminal needs a graphics-capable terminal (kitty / ghostty /
> WezTerm). A standard Windows console won't render them.

**Language providers** (all installed): Node.js (`npm i -g neovim`), Python (`pynvim`), Ruby
(`gem install neovim`), Perl (`Neovim::Ext`). Verify with `:checkhealth`.

---

## 4. Options / settings

`lua/config/options.lua` sets **no custom options** — it inherits
[LazyVim's defaults](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua):

| Option | Value | Meaning |
|--------|-------|---------|
| `number` / `relativenumber` | on | absolute + relative line numbers |
| `expandtab` / `shiftwidth` / `tabstop` | true / 2 / 2 | spaces, 2-wide indent |
| `clipboard` | `unnamedplus` | yank/paste use the system clipboard |
| `ignorecase` + `smartcase` | on | case-insensitive search unless you type a capital |
| `signcolumn` | `yes` | always-visible gutter |
| `mouse` | `a` | mouse enabled in all modes |
| `undofile` | on | persistent undo across sessions |
| `wrap` | off | long lines don't wrap |
| `scrolloff` | 4 | keep 4 lines of context around the cursor |
| `mapleader` | `Space` | the leader key |

Change an option in `lua/config/options.lua`, e.g. `vim.opt.wrap = true`.
`lua/config/lazy.lua` also sets `rocks = { enabled = false }`.

---

## 5. Plugins

### ★ Custom (`lua/plugins/`)

- **markview.nvim** — live, in-buffer markdown render: headings, fenced code blocks,
  `inline code`, **bold**, *italic*, tables, checkboxes, callouts, links, LaTeX. **Normal mode**
  is a clean read view; **insert mode** shows raw markdown so you can edit, and it re-renders
  automatically the moment you leave insert (`<Esc>` / `jk`). Toggle with `<leader>um`; if borders
  ever look broken, `<leader>mr` re-renders + forces a full redraw.
- **nvim-treesitter** (`treesitter.lua`) — adds the `latex` parser.

### Base (LazyVim) — active, browse with `:Lazy`

snacks.nvim (dashboard, picker, explorer, notifier, input, image, scroll, terminal, lazygit),
blink.cmp (completion), nvim-lspconfig + mason (LSP), conform + nvim-lint, nvim-treesitter,
which-key, noice, lualine, gitsigns, mini.ai / mini.pairs / mini.icons, flash, todo-comments,
trouble, grug-far.

---

## 6. The discipline system

Two habit-builders live in `lua/config/discipline.lua` + `lua/config/keymaps.lua`:

- **The "cowboy":** mashing `h` `j` `k` `l` `+` `-` **>10 times in a row** (with no count) pops a
  "Hold it Cowboy!" notification instead of moving — nudging you toward real motions
  (`w`, `}`, `5j`, `/search`). A real count like `10j` resets the counter (that's deliberate).
- **Arrows disabled** in **normal and insert** mode — they show a reminder instead of moving.
  Use `hjkl` + motions in normal mode, and the native insert keys (section 7) + a quick `jk`/`<Esc>`
  back to normal for editing.

Want arrows back in insert as a fallback? In `keymaps.lua` change `map({ "n", "i" }, ...)` to
`map("n", ...)` in the arrow loop.

---

## 7. Keybinding reference

Everything below: Vim / Neovim / LazyVim defaults **and** our ★ custom maps. Full authoritative
LazyVim list: <https://www.lazyvim.org/keymaps>. Discover live with `<leader>sk` (search
keymaps) or by pressing `<leader>` (which-key).

### Conditions — why a key can seem "dead"

Some keys only do something in the right context. If a key "does nothing," check here first:

- **Need ≥2 files (buffers) open:** `H` / `L` (Prev/Next Buffer), `[b` / `]b`, `<leader>bd`,
  `<leader>bo`. With a single file open they have nothing to switch to — *this is why `H`/`L`
  seemed dead while `M` worked.*
- **Need a language server attached** (open a supported file; install its LSP via `:Mason`):
  `gd` `gD` `gr` `gI` `gy` `K` `gK` `<leader>ca` `<leader>cr` `<leader>cf` `<leader>cd`
  `<leader>co` `]]` / `[[`.
- **Need a git repo** (gitsigns / lazygit): `<leader>gg` `<leader>gb` `<leader>gf`
  `]h` / `[h` `<leader>ghs` `<leader>ghr` `<leader>ghp`.
- **Need a markdown buffer** (markview): `<leader>um` `<leader>ms`.
- **Need the completion popup open** (insert): `<C-n>` / `<C-p>`.
- **Need an active snippet** (insert): `<Tab>` / `<S-Tab>` (otherwise they indent / de-indent).
- **Need a prior search:** `n` / `N`, and `*` / `#` (which start one).
- **Need a prior visual selection:** `gv`.
- **Need a prior change to repeat:** `.`.
- **Need diagnostics present:** `]d` / `[d`, `<leader>xx`.

### Modes

| Key | From | Action |
|-----|------|--------|
| `i` / `a` | vim | insert before / after cursor |
| `I` / `A` | vim | insert at first non-blank / end of line |
| `o` / `O` | vim | open new line below / above and insert |
| `v` / `V` / `<C-v>` | vim | visual char / line / block |
| `R` | vim | replace mode |
| `:` | vim | command-line |
| `<Esc>` / `jk` / `jj` | vim / ★ | leave insert/visual → normal |

### Moving around (normal mode — Vim built-ins)

| Key | Moves to |
|-----|----------|
| `h` `j` `k` `l` | left · down · up · right |
| `w` / `W` | start of next word / WORD (WORD = whitespace-delimited) |
| `e` / `E` | end of next word / WORD |
| `b` / `B` | start of previous word / WORD |
| `ge` | end of previous word |
| `0` / `^` / `$` | start of line / first non-blank / end of line |
| `f{c}` / `F{c}` | to next / previous `{c}` on the line (`;` / `,` repeat) |
| `t{c}` / `T{c}` | till before next / after previous `{c}` |
| `{` / `}` | previous / next blank-line paragraph |
| `(` / `)` | previous / next sentence |
| `%` | matching bracket `()[]{}` |
| `gg` / `G` | top / bottom of file · `{n}G` or `:{n}` = line n |
| `gh` / `gm` / `gl` | ★ cursor to top / middle / bottom of the visible screen ("go High/Middle/Low") |
| `M` | middle of screen (Vim built-in). Note: `H`/`L` are **remapped** to Prev/Next Buffer — see Buffers |
| `<C-d>` / `<C-u>` | ★ half page down / up (centered) |
| `<C-f>` / `<C-b>` | full page forward / back |
| `zz` / `zt` / `zb` | center / top / bottom the current line |
| `*` / `#` | search word under cursor forward / back |
| `n` / `N` | ★ next / prev search match (centered) |
| backtick-backtick / backtick-dot | jump to last cursor position / last edit |
| `<C-o>` / `<C-i>` | jump list back / forward |

### Insert mode (native — arrows are off here)

| Key | Action |
|-----|--------|
| `<C-w>` | delete the **word before** the cursor |
| `<C-u>` | delete from cursor to **start of line** |
| `<C-h>` | delete one char (Backspace) |
| `<C-Left>` / `<C-Right>` | move by **word** |
| `<C-r>{reg}` | insert the contents of register `{reg}` (e.g. `<C-r>+` = system clipboard) |
| `<C-o>{cmd}` | run one normal-mode command, then back to insert (e.g. `<C-o>dw`) |
| `<C-n>` / `<C-p>` | completion next / prev (blink.cmp) |
| `<Tab>` / `<S-Tab>` | jump snippet placeholder forward / back |
| `jk` / `jj` / `<Esc>` | ★ leave insert mode |

### Editing — operators, objects, registers (Vim built-ins)
An **operator** + a **motion/text-object** = an edit. `d`=delete, `c`=change, `y`=yank, `>`/`<`=indent, `gu`/`gU`=lower/upper, `=`=re-indent.

| Key | Action |
|-----|--------|
| `x` / `X` | delete char under / before cursor |
| `dd` / `cc` / `yy` | delete / change / yank whole line |
| `D` / `C` / `Y` | delete / change / yank to end of line |
| `dw` `db` `de` | delete to next word / prev word / end of word |
| `diw` / `daw` | delete **inner** word / **a** word (with surrounding space) |
| `di"` `di(` `dit` … | delete inside quotes / parens / html tag |
| `ciw` `ci"` `ca(` … | change inside/around a text object |
| `r{c}` / `s` / `S` | replace one char with `{c}` / substitute char / substitute line |
| `~` / `gu{m}` / `gU{m}` | toggle case / lowercase / uppercase over motion |
| `>>` / `<<` | indent / dedent line |
| `J` | ★ join line below (cursor kept) · `gJ` = join without space |
| `p` / `P` | paste after / before |
| `u` / `<C-r>` | undo / redo |
| `.` | **repeat** the last change |
| `gV` | ★ reselect the text you just pasted/changed |

**Text objects** (use after an operator, or in visual): `iw`/`aw` word · `is`/`as` sentence ·
`ip`/`ap` paragraph · `i"` `i'` `` i` `` quotes · `i(` `i[` `i{` `i<` brackets · `it`/`at` html
tag. mini.ai adds `if`/`af` function, `ic`/`ac` class, `a` next/last variants (`an`, `al`).

### Visual mode

| Key | Mode | Action |
|-----|------|--------|
| `v` / `V` / `<C-v>` | n | start char / line / block selection |
| `o` | x | jump to the other end of the selection |
| `gv` | n | reselect the last visual selection |
| `>` / `<` | x | ★ indent right / left, keep selection |
| `J` / `K` | x | ★ move the selection down / up |
| `p` | x | ★ paste over selection without losing your yank |
| `<M-j>` / `<M-k>` | x | move selection down / up (LazyVim) |

### Search & replace

| Key / cmd | Action |
|-----------|--------|
| `/` / `?` | search forward / backward |
| `n` / `N` | ★ next / prev match (centered) |
| `*` / `#` | search word under cursor |
| `<Esc>` | ★ clear search highlight |
| `:s/old/new/` | replace first on line · add `g` for all on line |
| `:%s/old/new/g` | replace in the whole file · add `c` to confirm each |
| `<leader>sr` | Search & Replace (grug-far, project-wide) |
| `<leader>/` | Grep the project (live) |

### Files, buffers & explorer (LazyVim)

| Key | Action |
|-----|--------|
| `<leader><leader>` | Find files (root dir) |
| `<leader>ff` / `<leader>fF` | Find files (root / cwd) |
| `<leader>fg` | Find git files |
| `<leader>fr` | Recent files |
| `<leader>fn` | New file |
| `<leader>fp` | Projects |
| `<leader>e` / `<leader>E` | Explorer (root / cwd) |
| `<leader>,` | Switch buffer (picker) |
| `` <leader>``  | Switch to the other/last buffer |
| `<S-h>` / `<S-l>` | previous / next buffer |
| `[b` / `]b` | previous / next buffer |
| `<leader>bd` | delete buffer — your **last** file lands on the dashboard (won't quit nvim) |
| `<leader>bo` | delete **other** buffers |
| `<leader>bD` | delete buffer **and** window |
| `<leader>bp` / `<leader>bP` | pin / delete non-pinned buffers |
| `<leader>H` | ★ **home** — close all files and go to the dashboard (start screen) |

> Auto-return: closing the **last** open file (e.g. `<leader>bd` on your only file) drops you
> back to the dashboard automatically. Unsaved files are kept, not force-closed.

#### Inside the file explorer (snacks.explorer — open with `<leader>e`)

These keys work **while the explorer window is focused** (it's a picker, so `/` filters live,
`<Esc>`/`q` closes it, `<CR>` or `l` opens, `<C-n>`/`<C-p>` move the selection).

| Key | Action |
|-----|--------|
| `H` | toggle **hidden** files (dotfiles like `.gitignore`) |
| `I` | toggle **ignored** files (git-ignored, e.g. `node_modules`) |
| `l` / `<CR>` | open file / expand directory |
| `h` | collapse (close) the directory |
| `<BS>` | go **up** to the parent directory |
| `.` | set the explorer's focus/root to the item under the cursor |
| `a` / `d` / `r` | **add** (new file/dir) / **delete** / **rename** |
| `c` / `m` | **copy** / **move** the item |
| `y` / `p` | **yank** (copy path) / **paste** the yanked item here |
| `o` | **open** with the system default application |
| `u` | refresh / **update** the tree |
| `P` | toggle the **preview** pane |
| `Z` | **close all** open directories |
| `<c-c>` | `tcd` — set tab-local cwd to the item |
| `<leader>/` | **grep** inside the focused directory |
| `]g` / `[g` | next / previous **git-changed** file |
| `]d` / `[d` · `]w` / `[w` · `]e` / `[e` | next/prev **diagnostic** · **warning** · **error** |

### Windows & splits

| Key | Action |
|-----|--------|
| `<leader>-` | split **below** (horizontal) |
| `<leader>\|` | split **right** (vertical) |
| `<C-w>s` / `<C-w>v` | split horizontal / vertical (raw Vim) |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | move focus left / down / up / right |
| `<C-Up>` `<C-Down>` `<C-Left>` `<C-Right>` | resize the current split |
| `<leader>wd` | close current window |
| `<leader>wm` | toggle **zoom** (maximize) the window |
| `<C-w>=` | equalize split sizes |
| `<C-w>o` | close **all other** windows |
| `<C-w>` `<Space>` | window "hydra" (keep resizing/moving without re-pressing `<C-w>`) |

### Tabs

| Key | Action |
|-----|--------|
| `<leader><Tab><Tab>` | new tab |
| `<leader><Tab>]` / `<leader><Tab>[` | next / previous tab |
| `<leader><Tab>f` / `<leader><Tab>l` | first / last tab |
| `<leader><Tab>d` / `<leader><Tab>o` | close this tab / close other tabs |
| `gt` / `gT` | next / previous tab (raw Vim) · `{n}gt` = tab n |

### Code / LSP (buffer-local — when a server is attached)

| Key | Action |
|-----|--------|
| `gd` / `gD` | go to definition / declaration |
| `gr` | references |
| `gI` | go to implementation |
| `gy` | go to type definition |
| `K` / `gK` | hover docs / signature help |
| `<leader>ca` | code action |
| `<leader>cr` | rename symbol · `<leader>cR` rename file |
| `<leader>cf` | format buffer |
| `<leader>cd` | line diagnostics |
| `<leader>cc` / `<leader>cC` | run / refresh codelens |
| `<leader>co` | organize imports |
| `<leader>cs` / `<leader>cS` | symbols / references (Trouble) |
| `<leader>cm` | Mason (LSP/tool installer) |
| `]]` / `[[` (or `<M-n>` / `<M-p>`) | next / prev reference |

### Diagnostics, quickfix & trouble

| Key | Action |
|-----|--------|
| `]d` / `[d` | next / previous diagnostic |
| `]e` / `[e` | next / previous **error** |
| `]w` / `[w` | next / previous **warning** |
| `<leader>xx` | diagnostics (Trouble) |
| `<leader>xX` | buffer diagnostics (Trouble) |
| `<leader>xl` / `<leader>xq` | location / quickfix list |
| `<leader>xt` | todo/fixme (Trouble) |
| `]q` / `[q` | next / previous quickfix item |

### Git (buffer-local — gitsigns + snacks)

| Key | Action |
|-----|--------|
| `<leader>gg` | **lazygit** (full git UI) |
| `<leader>gb` | git blame line |
| `<leader>gf` | current file history |
| `<leader>gl` / `<leader>gL` | git log (root / cwd) |
| `<leader>gs` | git status |
| `<leader>gd` | git diff (hunks) |
| `<leader>gB` / `<leader>gY` | open / copy git browse (GitHub link) |
| `]h` / `[h` | next / previous hunk (gitsigns) |
| `<leader>ghs` / `<leader>ghr` | stage / reset hunk |
| `<leader>ghp` | preview hunk |

### Search menu — pickers (`<leader>s…`)

| Key | Action |
|-----|--------|
| `<leader>sk` | **keymaps** (search all your bindings) |
| `<leader>sh` | help pages |
| `<leader>sg` / `<leader>sG` | grep (root / cwd) |
| `<leader>sw` / `<leader>sW` | grep word/selection (root / cwd) |
| `<leader>sb` | search lines in buffer |
| `<leader>sd` | diagnostics |
| `<leader>ss` | LSP symbols |
| `<leader>st` | todo comments |
| `<leader>sr` | search & replace (grug-far) |
| `<leader>su` | undo tree |
| `<leader>sc` / `<leader>s"` | command history / registers |
| `<leader>sm` / `<leader>sj` | marks / jumps |

### UI toggles (`<leader>u…`)

| Key | Toggles |
|-----|---------|
| `<leader>uw` | line wrap |
| `<leader>ul` / `<leader>uL` | line numbers / relative numbers |
| `<leader>ud` | diagnostics |
| `<leader>uh` | inlay hints |
| `<leader>uc` | conceal level |
| `<leader>uf` / `<leader>uF` | auto-format (global / buffer) |
| `<leader>us` | spelling |
| `<leader>ug` | indent guides |
| `<leader>uz` / `<leader>uZ` | zen / zoom mode |
| `<leader>un` | dismiss all notifications |
| `<leader>ur` | redraw / clear hlsearch / diff update |
| `<leader>um` | ★ toggle markdown render |

### Comments (built-in `gc` + LazyVim)

| Key | Action |
|-----|--------|
| `gcc` | toggle comment on the line |
| `gc{motion}` | toggle comment over a motion (e.g. `gcap`, `gc2j`) |
| `gc` (visual) | toggle comment on selection |
| `gco` / `gcO` | add comment line below / above |

### Markdown (markview)

 Key | Action |
|-----|--------|
| `<leader>um` | ★ toggle render (`:Markview Toggle`) |
| `<leader>ms` | ★ split preview (`:Markview splitToggle`) |
| `<leader>mr` | ★ re-render + full redraw — use if table/heading borders ever look broken |

### System clipboard (`+` register)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>y` / `<leader>Y` | n, x | ★ yank (line) to system clipboard |
| `<leader>P` | n, x | ★ paste from system clipboard |
| `"+y` / `"+p` | n, x | yank / paste via the `+` (system) register |

### Misc

| Key | Action |
|-----|--------|
| `<C-s>` | ★ save file |
| `<leader>qq` | quit all |
| `<leader>l` | Lazy (plugin manager) |
| `<leader>n` | notification history |

---

## 8. User commands

| Command | Action |
|---------|--------|
| `:Home` | ★ close all files and go to the dashboard (homepage) — stays in Neovim. Also `<leader>H` |
| `:Quit` / `:Quit!` | ★ close all files **and** exit Neovim (`:qa` / `:qa!`). Also `<leader>qq` |
| `:TrimWhitespace` | ★ remove trailing whitespace across the file (cursor kept) |
| `:Cd` | ★ cd to the current file's folder |
| `:Markview Toggle` | toggle in-buffer markdown render |
| `:Markview splitToggle` | live rendered preview in a split |
| `:Markview HybridToggle` | toggle hybrid edit mode (raw on cursor line) |
| `:Lazy` / `:LazyExtras` | plugin manager / enable-disable extras |
| `:Mason` | LSP / tool installer |
| `:checkhealth` | diagnose the setup |

---

## 9. Launching, maintenance & health

- **Launch:** `nvim <file>` runs Neovim in the current terminal (`vi` is a PowerShell alias).
  Image previews need a graphics-capable terminal.
- **Update:** plugins `:Lazy sync` · LSP/tools `:Mason` · parsers `:TSUpdate`.
- **Health:** `:checkhealth`. All ✅ except any language toolchain (Go/Rust/Java/Julia) you
  haven't installed — those are opt-in per language.

### Informational-only checkhealth items (safe to ignore)
- which-key "overlapping keymaps" (`gc`, `a`, `i`) — prefix relationships (comment operator,
  mini.ai text objects), **not** conflicts.
- blink "disabled" sources, snacks `statuscolumn`/`image` "disabled" — dynamic or opt-in.
- mason "not available" for Go/cargo/java/julia — only needed when you install a tool that uses them.

### Reference
LazyVim keymaps <https://www.lazyvim.org/keymaps> 
options <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua> 
docs <https://www.lazyvim.org>.
