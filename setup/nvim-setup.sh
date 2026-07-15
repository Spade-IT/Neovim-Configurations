#!/usr/bin/env bash
# Install Neovim + every dependency LazyVim / snacks.nvim / lazy.nvim ask for.
# Supports macOS (Homebrew) and Linux (apt / dnf / pacman / zypper).
# Idempotent-ish: your package manager will skip anything already installed.
#
# Usage:   bash nvim-setup.sh
# After it finishes, restart your shell and run  :checkhealth  in Neovim.
set -u

info(){ printf '\033[36m==> %s\033[0m\n' "$*"; }
ok(){   printf '\033[32m  OK  %s\033[0m\n' "$*"; }
warn(){ printf '\033[33m  !!  %s\033[0m\n' "$*"; }

SUDO=""; [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"

detect_pm() {
  if [ "$(uname -s)" = "Darwin" ]; then echo "brew"; return; fi
  for pm in apt-get dnf pacman zypper; do
    command -v "$pm" >/dev/null 2>&1 && { echo "$pm"; return; }
  done
  echo "unknown"
}
PM="$(detect_pm)"
info "Package manager: $PM"

# ---- system tools (names differ per distro) --------------------------------
install_system() {
  case "$PM" in
    brew)
      command -v brew >/dev/null 2>&1 || { warn "Install Homebrew first: https://brew.sh"; return 1; }
      brew install neovim git ripgrep fd fzf lazygit node imagemagick ghostscript \
                   tectonic tree-sitter ruby luarocks ast-grep
      # Image previews need a graphics-capable terminal (kitty/ghostty/wezterm) - install one
      # yourself if you want them, e.g.:  brew install --cask wezterm
      ;;
    apt-get)
      $SUDO apt-get update
      $SUDO apt-get install -y neovim git ripgrep fd-find fzf imagemagick ghostscript \
                   nodejs npm perl ruby-full luarocks xclip wl-clipboard build-essential curl
      # lazygit / tectonic / tree-sitter-cli / wezterm are not in default apt; see notes below.
      warn "lazygit, tectonic, tree-sitter-cli, wezterm: install from their releases (see script footer)."
      ;;
    dnf)
      $SUDO dnf install -y neovim git ripgrep fd-find fzf lazygit ImageMagick ghostscript \
                   nodejs npm perl ruby rubygems luarocks tree-sitter-cli wl-clipboard xclip @development-tools curl
      $SUDO dnf install -y tectonic wezterm 2>/dev/null || warn "tectonic/wezterm may need a COPR repo."
      ;;
    pacman)
      $SUDO pacman -Sy --needed --noconfirm neovim git ripgrep fd fzf lazygit imagemagick ghostscript \
                   nodejs npm perl ruby luarocks tree-sitter-cli tectonic wezterm wl-clipboard xclip base-devel curl
      ;;
    zypper)
      $SUDO zypper install -y neovim git ripgrep fd fzf lazygit ImageMagick ghostscript \
                   nodejs npm perl ruby ruby-devel lua51-luarocks wl-clipboard xclip curl
      warn "tectonic, tree-sitter-cli, wezterm: install from their releases (see script footer)."
      ;;
    *)
      warn "Unknown package manager. Install the tools listed in the script header manually."
      return 1
      ;;
  esac
}

info "Installing system tools"
install_system

# ---- language providers (same everywhere) ----------------------------------
info "Node provider + Mermaid CLI (mmdc)"
if command -v npm >/dev/null 2>&1; then
  $SUDO npm install -g neovim @mermaid-js/mermaid-cli && ok "npm: neovim + mermaid-cli"
else warn "npm missing; install Node.js, then: npm i -g neovim @mermaid-js/mermaid-cli"; fi

info "Python provider (pynvim)"
if command -v python3 >/dev/null 2>&1; then
  python3 -m pip install --user --upgrade pynvim 2>/dev/null \
    || pipx install pynvim 2>/dev/null \
    || warn "pip failed; try: python3 -m pip install --break-system-packages pynvim"
  ok "pynvim"
else warn "python3 missing"; fi

info "Ruby provider"
command -v gem >/dev/null 2>&1 && { $SUDO gem install neovim && ok "gem: neovim"; } || warn "gem missing"

info "Perl provider"
if command -v cpanm >/dev/null 2>&1; then cpanm -n Neovim::Ext 2>/dev/null && ok "perl: Neovim::Ext"; else
  warn "cpanm missing; optional. Or disable in init: let g:loaded_perl_provider = 0"; fi

# ---- luarocks for lazy.nvim ------------------------------------------------
if command -v luarocks >/dev/null 2>&1; then ok "luarocks present ($(luarocks --version | head -1))"
else warn "luarocks not installed; or disable in LazyVim: opts.rocks.hererocks = false"; fi

cat <<'NOTES'

Done. Restart your shell, then run :checkhealth in Neovim.

Manual bits some distros lack a package for:
  - lazygit    : https://github.com/jesseduffield/lazygit/releases
  - tectonic   : https://tectonic-typesetting.github.io/  (LaTeX math previews)
  - tree-sitter: `npm i -g tree-sitter-cli`  or  `cargo install tree-sitter-cli`
  - wezterm    : https://wezterm.org  (a terminal that supports image graphics)

Informational (safe to ignore): "disabled" completion sources, which-key key
overlaps, snacks.statuscolumn "disabled".
NOTES
