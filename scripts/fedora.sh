#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Distro Check
# ==============================================================================
if [[ -f /etc/os-release ]]; then
  # shellcheck source=/dev/null
  source /etc/os-release
  if [[ "${ID:-}" != "fedora" && "${ID_LIKE:-}" != *"fedora"* ]]; then
    echo "Warning: This installer is intended for Fedora. Detected: ${NAME:-Unknown Linux}." >&2
  fi
else
  echo "Warning: /etc/os-release not found. Proceeding assuming Fedora-compatible environment." >&2
fi

if ! command -v dnf >/dev/null 2>&1; then
  echo "Error: dnf package manager not found." >&2
  exit 1
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

echo "==> Checking and installing Fedora packages: ${PACKAGES[*]}..."
"${SUDO_CMD[@]}" dnf install -y "${PACKAGES[@]}"

# ==============================================================================
# Configure .zshrc Symlink
# ==============================================================================
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_HOME="${HOME:-/root}"
TARGET_ZSHRC="${TARGET_HOME}/.zshrc"

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
fi

# ==============================================================================
# Verification & Summary
# ==============================================================================
echo ""
echo "================================================================================"
echo " Fedora Zsh Setup Complete"
echo "================================================================================"
echo "Symlink:      ${TARGET_ZSHRC} -> $(readlink -f "${TARGET_ZSHRC}")"
echo "Zsh:          $("${ZSH_BIN}" --version)"
echo "ripgrep:      $(rg --version | head -n 1)"
echo "fd:           $(fd --version)"
echo "Autosuggest:  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
echo "Highlighting: /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
echo "================================================================================"
