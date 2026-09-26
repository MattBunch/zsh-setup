# zsh-setup

[![CI](https://github.com/MattBunch/zsh-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/MattBunch/zsh-setup/actions/workflows/ci.yml)

A portable, modular, version-controlled Zsh configuration and automated installer designed for Linux workstations.

---

## Distribution Support

- **Supported Now**:
  - Fedora (`scripts/fedora.sh`)
- **Planned Support**:
  - Ubuntu / Debian (`scripts/ubuntu.sh`)
  - Arch Linux (`scripts/arch.sh`)

---

## Features

- **Shell & Tools**:
  - Zsh with modern interactive defaults
  - Fast file search with `fd`
  - Fast text search with `ripgrep` (`rg`)
- **Completion**:
  - Native Zsh completion (`compinit`)
  - Case-insensitive completion matching (`m:{a-zA-Z}={A-Za-z}`)
  - Visual menu completion selection
- **History**:
  - Shared, persistent history (`~/.zsh_history`, 50,000 entries)
  - Duplicate reduction and blank removal
  - Prefix history search using Up / Down arrow keys (e.g. type `git` and press Up)
  - Seamless Left / Right cursor movement
- **Plugins**:
  - `zsh-autosuggestions` (distro packaged)
  - `zsh-syntax-highlighting` (distro packaged)
- **Modularity & Security**:
  - Sourced `~/.zshrc.local` for machine-specific settings and secrets (ignored by Git)

---

## Installation on Fedora

Clone the repository and run the Fedora setup script:

```bash
git clone git@github.com:MattBunch/zsh-setup.git
cd zsh-setup
./scripts/fedora.sh
```

### What the installer does:
1. Installs required system packages via `dnf`:
   - `zsh`
   - `ripgrep`
   - `fd-find` (provides `fd`)
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
2. Backs up any existing regular `~/.zshrc` file to `~/.zshrc.backup-<timestamp>`.
3. Creates a symlink pointing `~/.zshrc` to `<repository>/.zshrc`.
4. Changes your default login shell to Zsh (unless skipped via `ZSH_SETUP_SKIP_CHSH=1`).

---

## Machine-Local Configuration

For sensitive values, work-specific variables, API keys, or machine-specific paths, create:

```bash
touch ~/.zshrc.local
```

The primary `.zshrc` automatically sources `~/.zshrc.local` if it exists at startup:

```zsh
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
```

`~/.zshrc.local` is explicitly excluded from version control in `.gitignore`.
