<#
.SYNOPSIS
    Install Neovim + every dependency LazyVim / snacks.nvim / lazy.nvim ask for on Windows.

.DESCRIPTION
    Idempotent: skips anything already present. Uses winget for system tools, npm/pip/gem for
    the language "providers", and hererocks for lazy.nvim's optional luarocks support.

    Run in a NORMAL PowerShell (a few machine-scope installers may pop a UAC prompt - approve
    them). After it finishes, restart your terminal and run  :checkhealth  in Neovim.

.NOTES
    Tools installed:
      core     : neovim, git, ripgrep(rg), fd, fzf, lazygit, tree-sitter-cli, curl (built in)
      node     : Node.js  + `npm i -g neovim` (node provider) + mermaid-cli (mmdc)
      python   : pynvim (python3 provider)
      ruby     : Ruby + `gem install neovim` (ruby provider)
      perl     : Strawberry Perl (perl provider)
      images   : ImageMagick(magick), Ghostscript(gs), Tectonic(LaTeX), WezTerm(graphics term)
      luarocks : hererocks (lua 5.1 + luarocks) for lazy.nvim
#>

[CmdletBinding()]
param(
    [switch]$SkipHeavy   # skip Perl, Ruby, Tectonic, WezTerm (the large / optional ones)
)

$ErrorActionPreference = 'Continue'
function Info($m){ Write-Host "==> $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "  OK  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "  !!  $m" -ForegroundColor Yellow }

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Warn "winget not found. Install 'App Installer' from the Microsoft Store, then re-run."
    return
}

# Install a winget package unless the probe command already resolves.
function Install-WG {
    param([string]$Id, [string]$Probe)
    if ($Probe -and (Get-Command $Probe -ErrorAction SilentlyContinue)) { Ok "$Probe already installed"; return }
    Info "Installing $Id ..."
    winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity | Out-Null
    if ($LASTEXITCODE -eq 0) { Ok "$Id" } else { Warn "$Id (winget exit $LASTEXITCODE - may need admin, or already installed)" }
}

Info "Core editor + finder tools"
Install-WG 'Neovim.Neovim'            'nvim'
Install-WG 'Git.Git'                  'git'
Install-WG 'BurntSushi.ripgrep.MSVC'  'rg'
Install-WG 'sharkdp.fd'               'fd'
Install-WG 'junegunn.fzf'             'fzf'
Install-WG 'JesseDuffield.lazygit'    'lazygit'
Install-WG 'tree-sitter.tree-sitter-cli' 'tree-sitter'
Install-WG 'ast-grep.ast-grep'        'ast-grep'   # structural search for grug-far
Install-WG 'OpenJS.NodeJS'            'node'

# Ghostscript isn't in the winget default source, so pull Artifex's official release and
# shim `gs` -> `gswin64c` (Windows names the binary gswin64c; snacks.image looks for `gs`).
function Install-Ghostscript {
    if (Get-Command gs -ErrorAction SilentlyContinue) { Ok "gs already available"; return }
    Info "Installing Ghostscript (official release)..."
    try {
        $rel = Invoke-RestMethod "https://api.github.com/repos/ArtifexSoftware/ghostpdl-downloads/releases/latest" -Headers @{ "User-Agent"="setup" }
        $asset = $rel.assets | Where-Object { $_.name -match 'gs\d+w64\.exe$' } | Select-Object -First 1
        $exe = "$env:TEMP\$($asset.name)"
        Invoke-WebRequest $asset.browser_download_url -OutFile $exe
        Start-Process $exe -ArgumentList "/S" -Wait
        $gsw = (Get-ChildItem "C:\Program Files\gs\*\bin\gswin64c.exe" -ErrorAction SilentlyContinue | Select-Object -Last 1).FullName
        $prefix = (npm config get prefix 2>$null)
        if ($gsw -and $prefix -and (Test-Path $prefix)) { "@`"$gsw`" %*" | Set-Content -Encoding ASCII "$prefix\gs.cmd"; Ok "gs -> $gsw" }
        else { Warn "Ghostscript installed as gswin64c; add a 'gs' shim manually if snacks still complains." }
    } catch { Warn "Ghostscript install failed: $($_.Exception.Message)" }
}

Info "Image / document rendering tools (snacks.image)"
Install-WG 'ImageMagick.ImageMagick'  'magick'
Install-Ghostscript
# Tectonic (LaTeX math previews) isn't in winget; grab its official Windows binary.
function Install-Tectonic {
    if (Get-Command tectonic -ErrorAction SilentlyContinue) { Ok "tectonic already installed"; return }
    Info "Installing Tectonic (official binary)..."
    try {
        $rel = Invoke-RestMethod "https://api.github.com/repos/tectonic-typesetting/tectonic/releases/latest" -Headers @{ "User-Agent"="setup" }
        $asset = $rel.assets | Where-Object { $_.name -match 'x86_64-pc-windows-msvc\.zip$' } | Select-Object -First 1
        $zip = "$env:TEMP\$($asset.name)"
        Invoke-WebRequest $asset.browser_download_url -OutFile $zip
        Expand-Archive $zip -DestinationPath "$env:TEMP\tectonic_x" -Force
        $exe = (Get-ChildItem "$env:TEMP\tectonic_x" -Recurse -Filter tectonic.exe | Select-Object -First 1).FullName
        $prefix = (npm config get prefix 2>$null); Copy-Item $exe "$prefix\tectonic.exe" -Force
        Ok "tectonic -> $prefix\tectonic.exe"
    } catch { Warn "Tectonic install failed: $($_.Exception.Message)" }
}

if (-not $SkipHeavy) {
    # NOTE: image previews need a graphics-capable terminal (kitty / ghostty / WezTerm).
    # Install one yourself if you want them, e.g.:  winget install wez.wezterm
    Install-Tectonic
}

if (-not $SkipHeavy) {
    Info "Optional language providers (Perl / Ruby)"
    Install-WG 'StrawberryPerl.StrawberryPerl' 'perl'
    Install-WG 'RubyInstallerTeam.Ruby.3.4'    'ruby'
}

# Refresh PATH for this session so freshly-installed npm/gem are callable.
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path','User')

Info "Node provider + Mermaid CLI (mmdc)"
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm install -g neovim                      | Out-Null; Ok "npm: neovim"
    npm install -g @mermaid-js/mermaid-cli     | Out-Null; Ok "npm: @mermaid-js/mermaid-cli (mmdc)"
    # npm >= 12 blocks install-scripts by default, so mermaid's puppeteer skips its Chromium
    # download. mmdc still satisfies :checkhealth; fetch Chromium on first real use:
    Warn "If mermaid rendering fails, run: npx puppeteer browsers install chrome-headless-shell"
} else { Warn "npm not on PATH yet - reopen terminal, then: npm i -g neovim @mermaid-js/mermaid-cli" }

Info "Python provider (pynvim)"
$pyCandidates = @(
    "$env:LOCALAPPDATA\Python\pythoncore-3.14-64\python.exe",
    "$env:LOCALAPPDATA\Python\bin\python.exe"
) + @( (Get-Command python -ErrorAction SilentlyContinue).Source )
$py = $pyCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if ($py) { & $py -m pip install --upgrade pynvim | Out-Null; Ok "pynvim into $py" }
else { Warn "No python found - run: python -m pip install pynvim" }

if (-not $SkipHeavy -and (Get-Command gem -ErrorAction SilentlyContinue)) {
    Info "Ruby provider (needs the MSYS2 dev toolchain to build msgpack)"
    if (Get-Command ridk -ErrorAction SilentlyContinue) { ridk install 3 2>&1 | Out-Null }
    gem install neovim 2>&1 | Out-Null
    if ((gem list neovim 2>$null) -match 'neovim') { Ok "gem: neovim" }
    else { Warn "Ruby gem failed (msgpack build). Either run 'ridk install 3' in a fresh shell, or disable the provider: vim.g.loaded_ruby_provider = 0" }
}

Info "luarocks support for lazy.nvim (hererocks)"
if ($py) {
    & $py -m pip install --upgrade hererocks | Out-Null
    $rocks = "$env:LOCALAPPDATA\nvim-data\lazy-rocks\hererocks"
    & $py -m hererocks $rocks --lua 5.1 --luarocks latest 2>$null
    if (Test-Path "$rocks\bin\luarocks.bat") { Ok "hererocks (lua 5.1 + luarocks) at $rocks" }
    else { Warn "hererocks build needs a C/MSVC compiler. Alternatively disable it in your LazyVim config: opts.rocks.hererocks = false" }
}

Write-Host ""
Info "Done. Restart your terminal, then run :checkhealth in Neovim."
Write-Host "  - Terminal image previews need a graphics-capable terminal: launch nvim inside WezTerm." -ForegroundColor DarkGray
Write-Host "  - 'disabled' completion sources, which-key overlaps, statuscolumn 'disabled' are informational only." -ForegroundColor DarkGray
