#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Distro & Environment Check
# ==============================================================================
if [[ -f /etc/os-release ]]; then
  # shellcheck source=/dev/null
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" && "${ID:-}" != "debian" && "${ID_LIKE:-}" != *"ubuntu"* && "${ID_LIKE:-}" != *"debian"* ]]; then
    echo "Warning: This installer is intended for Ubuntu/Debian. Detected: ${NAME:-Unknown Linux}." >&2
  fi
else
  echo "Warning: /etc/os-release not found. Proceeding assuming Ubuntu-compatible environment." >&2
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Error: apt-get package manager not found." >&2
  exit 1
fi

# Detect WSL / WSL2 environment
IS_WSL=0
IS_WSL2=0

if [[ "${ZSH_SETUP_FORCE_WSL:-0}" == "1" ]]; then
  IS_WSL=1
  IS_WSL2=1
elif [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -f /proc/sys/kernel/osrelease && "$(cat /proc/sys/kernel/osrelease)" =~ [Mm]icrosoft ]] || [[ "$(uname -r)" =~ [Mm]icrosoft ]]; then
  IS_WSL=1
  if [[ -n "${WSL_INTEROP:-}" ]] || [[ -f /proc/sys/kernel/osrelease && "$(cat /proc/sys/kernel/osrelease)" =~ WSL2 ]] || [[ "$(uname -r)" =~ WSL2 ]]; then
    IS_WSL2=1
  fi
fi

if [[ "${IS_WSL2}" -eq 1 ]]; then
  echo "==> Detected environment: Ubuntu on WSL2"
elif [[ "${IS_WSL}" -eq 1 ]]; then
  echo "==> Detected environment: Ubuntu on WSL"
else
  echo "==> Detected environment: Native Ubuntu"
fi

# ==============================================================================
# Privilege Escalation
# ==============================================================================
if [[ "${EUID}" -eq 0 ]]; then
  SUDO_CMD=()
else
  if command -v sudo >/dev/null 2>&1; then
    SUDO_CMD=(sudo)
  else
    echo "Error: Root privileges or sudo required to install packages." >&2
    exit 1
  fi
fi

# ==============================================================================
# Install Required Packages
# ==============================================================================
PACKAGES=(
  zsh
  ripgrep
  fd-find
  zsh-autosuggestions
  zsh-syntax-highlighting
)

echo "==> Updating package indexes and installing Ubuntu packages: ${PACKAGES[*]}..."
export DEBIAN_FRONTEND=noninteractive
"${SUDO_CMD[@]}" apt-get update -y
"${SUDO_CMD[@]}" apt-get install -y "${PACKAGES[@]}"

# ==============================================================================
# Configure Portable 'fd' Compatibility
# ==============================================================================
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_HOME="${HOME:-/root}"
TARGET_ZSHRC="${TARGET_HOME}/.zshrc"

# Ensure ~/.local/bin exists in target home
mkdir -p "${TARGET_HOME}/.local/bin"
export PATH="${TARGET_HOME}/.local/bin:${PATH}"

if ! command -v fd >/dev/null 2>&1; then
  if command -v fdfind >/dev/null 2>&1; then
    FDFIND_BIN="$(command -v fdfind)"
    echo "==> Creating portable 'fd' symlink: ${TARGET_HOME}/.local/bin/fd -> ${FDFIND_BIN}..."
    ln -sfn "${FDFIND_BIN}" "${TARGET_HOME}/.local/bin/fd"
  else
    echo "Warning: Neither 'fd' nor 'fdfind' command was found." >&2
  fi
else
  echo "==> Command 'fd' is already available: $(command -v fd)"
fi

# ==============================================================================
# Configure .zshrc Symlink
# ==============================================================================
echo "==> Configuring .zshrc in ${TARGET_HOME}..."

if [[ -L "${TARGET_ZSHRC}" ]]; then
  CURRENT_TARGET="$(readlink -f "${TARGET_ZSHRC}" || true)"
  REPO_ZSHRC="$(readlink -f "${REPO_ROOT}/.zshrc" || true)"
  if [[ "${CURRENT_TARGET}" == "${REPO_ZSHRC}" ]]; then
    echo "Symlink already correctly points to ${REPO_ROOT}/.zshrc."
  else
    echo "Updating existing symlink from ${CURRENT_TARGET} to ${REPO_ROOT}/.zshrc..."
    ln -sfn "${REPO_ROOT}/.zshrc" "${TARGET_ZSHRC}"
  fi
elif [[ -f "${TARGET_ZSHRC}" ]]; then
  BACKUP_PATH="${TARGET_ZSHRC}.backup-$(date +%Y%m%d-%H%M%S)"
  echo "Backing up existing regular file ${TARGET_ZSHRC} to ${BACKUP_PATH}..."
  cp -p "${TARGET_ZSHRC}" "${BACKUP_PATH}"
  ln -sfn "${REPO_ROOT}/.zshrc" "${TARGET_ZSHRC}"
else
  echo "Creating symlink ${TARGET_ZSHRC} -> ${REPO_ROOT}/.zshrc..."
  ln -sfn "${REPO_ROOT}/.zshrc" "${TARGET_ZSHRC}"
fi

# ==============================================================================
# Configure Login Shell
# ==============================================================================
ZSH_BIN="$(command -v zsh || true)"
if [[ -z "${ZSH_BIN}" ]]; then
  echo "Error: zsh executable not found after package installation." >&2
  exit 1
fi

if [[ "${ZSH_SETUP_SKIP_CHSH:-0}" == "1" ]]; then
  echo "==> Skipping login shell modification (ZSH_SETUP_SKIP_CHSH=1)."
else
  USER_NAME="${USER:-$(id -un)}"
  CURRENT_LOGIN_SHELL="$(getent passwd "${USER_NAME}" 2>/dev/null | cut -d: -f7 || echo "${SHELL:-}")"

  if [[ "${CURRENT_LOGIN_SHELL}" != "${ZSH_BIN}" ]]; then
    echo "==> Updating login shell for ${USER_NAME} to ${ZSH_BIN}..."
    if command -v chsh >/dev/null 2>&1; then
      chsh -s "${ZSH_BIN}" "${USER_NAME}" || chsh -s "${ZSH_BIN}"
    else
      echo "Warning: chsh command not found. Please set your login shell manually to ${ZSH_BIN}." >&2
    fi
  else
    echo "==> Login shell is already ${ZSH_BIN}."
  fi

  if [[ "${IS_WSL}" -eq 1 ]]; then
    echo "Note: If your new login shell is not active in new WSL sessions, close and relaunch your WSL session from Windows (e.g. 'wsl.exe --terminate <distro>' or restart Windows Terminal)."
  fi
fi

# ==============================================================================
# Verification & Summary
# ==============================================================================
FD_BIN="$(command -v fd || true)"

echo ""
echo "================================================================================"
if [[ "${IS_WSL2}" -eq 1 ]]; then
  echo " Ubuntu on WSL2 Zsh Setup Complete"
elif [[ "${IS_WSL}" -eq 1 ]]; then
  echo " Ubuntu on WSL Zsh Setup Complete"
else
  echo " Ubuntu Zsh Setup Complete"
fi
echo "================================================================================"
echo "Symlink:      ${TARGET_ZSHRC} -> $(readlink -f "${TARGET_ZSHRC}")"
echo "Zsh:          $("${ZSH_BIN}" --version)"
echo "ripgrep:      $(rg --version | head -n 1)"
echo "fd:           $("${FD_BIN}" --version 2>/dev/null || echo 'fd (fdfind mapped)')"
echo "Autosuggest:  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
echo "Highlighting: /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
echo "================================================================================"
