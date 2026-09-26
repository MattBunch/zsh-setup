# zsh-setup

[![CI](https://github.com/MattBunch/zsh-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/MattBunch/zsh-setup/actions/workflows/ci.yml)

My Zsh configuration.

---

## Distribution Support

- **Supported Now**:
  - **Fedora** (`scripts/fedora.sh`)
  - **Ubuntu / Debian** (`scripts/ubuntu.sh`)
  - **Ubuntu on WSL2** (`scripts/ubuntu.sh`)
- **Planned Support**:
  - Arch Linux (`scripts/arch.sh`)

---

## Features

- **Shell & Tools**:
  - Zsh with modern interactive defaults
  - Fast file search with `fd` (automatically handled across distros)
  - Fast text search with `ripgrep` (`rg`)
  - Dynamic terminal tab / window titles
- **Navigation & Editing**:
  - <kbd>Left</kbd> / <kbd>Right</kbd> -> Move cursor one character
  - <kbd>Ctrl</kbd> + <kbd>Left</kbd> / <kbd>Right</kbd> -> Move cursor one word backward/forward
  - <kbd>Alt</kbd> + <kbd>Left</kbd> / <kbd>Right</kbd> -> Move cursor one word backward/forward
  - <kbd>Alt</kbd>+<kbd>B</kbd> / <kbd>Alt</kbd>+<kbd>F</kbd> -> Traditional Emacs word navigation
- **Completion**:
  - Native Zsh completion (`compinit`)
  - Case-insensitive completion matching (`m:{a-zA-Z}={A-Za-z}`)
  - Visual menu completion selection
- **History**:
  - Shared, persistent history (`~/.zsh_history`, 50,000 entries)
  - Duplicate reduction and blank removal
  - <kbd>Up</kbd> / <kbd>Down</kbd> -> Prefix history search (e.g. type `git` and press Up)
- **Plugins**:
  - `zsh-autosuggestions` (distro packaged)
  - `zsh-syntax-highlighting` (distro packaged, loaded last)
- **Modularity & Security**:
  - Sourced `~/.zshrc.local` for machine-specific settings, custom tool paths, and secrets (ignored by Git)

---

## Installation

Clone the repository and run the universal installer:

```bash
git clone git@github.com:MattBunch/zsh-setup.git
cd zsh-setup
./install.sh
```

The universal `install.sh` automatically detects your Linux distribution from `/etc/os-release` and dispatches to the appropriate distribution script.

You can also invoke distro-specific scripts directly:
- Fedora: `./scripts/fedora.sh`
- Ubuntu / Debian / WSL2: `./scripts/ubuntu.sh`

### What the installer does:
1. Installs required system packages via your package manager (`dnf` on Fedora, `apt-get` on Ubuntu/WSL2):
   - `zsh`
   - `ripgrep`
   - `fd-find`
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
2. Configures portable `fd` on Ubuntu/Debian (creates a user symlink `~/.local/bin/fd` -> `fdfind` so `fd` commands work consistently everywhere).
3. Backs up any existing regular `~/.zshrc` file to `~/.zshrc.backup-<timestamp>`.
4. Creates a symlink pointing `~/.zshrc` to `<repository>/.zshrc`.
5. Changes your default login shell to Zsh (unless skipped via `ZSH_SETUP_SKIP_CHSH=1`).

---

## Ubuntu on WSL2

`scripts/ubuntu.sh` automatically detects WSL2 environments.

### Best Practices for WSL2:
1. Ensure Ubuntu is installed in WSL2.
2. Clone this repository directly inside the Linux filesystem (e.g. `~/Projects/zsh-setup`), not on the Windows filesystem mounted at `/mnt/c/`.
3. Run `./install.sh` inside your WSL Ubuntu shell.
4. If your default shell does not update immediately in existing Windows Terminal tabs, close and relaunch your WSL session from Windows (e.g., `wsl.exe --terminate <DistroName>` or restart Windows Terminal).

---

## Machine-Local Configuration

For sensitive values, work-specific variables, API keys, or machine-specific tool paths (such as OpenCode or proprietary CLI binaries), create or edit:

```bash
touch ~/.zshrc.local
```

Example `~/.zshrc.local`:
```zsh
# Machine-local tools
if [[ -d "$HOME/.opencode/bin" ]]; then
  path=("$HOME/.opencode/bin" $path)
fi
```

The primary `.zshrc` automatically sources `~/.zshrc.local` if it exists at startup:

```zsh
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
```

`~/.zshrc.local` is explicitly excluded from version control in `.gitignore`.
