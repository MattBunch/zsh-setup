#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Universal Linux Zsh Setup Dispatcher
# ==============================================================================
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f /etc/os-release ]]; then
  echo "Error: /etc/os-release not found. Cannot determine Linux distribution." >&2
  exit 1
fi

# shellcheck source=/dev/null
source /etc/os-release

DISTRO_ID="${ID:-unknown}"
DISTRO_LIKE="${ID_LIKE:-}"

echo "==> Detected Linux distribution: ${NAME:-$DISTRO_ID} (ID=${DISTRO_ID}, ID_LIKE=${DISTRO_LIKE})"

case "${DISTRO_ID}" in
  fedora)
    exec "${REPO_ROOT}/scripts/fedora.sh"
    ;;
  ubuntu|debian)
    exec "${REPO_ROOT}/scripts/ubuntu.sh"
    ;;
  *)
    if [[ "${DISTRO_LIKE}" == *"fedora"* ]]; then
      exec "${REPO_ROOT}/scripts/fedora.sh"
    elif [[ "${DISTRO_LIKE}" == *"ubuntu"* || "${DISTRO_LIKE}" == *"debian"* ]]; then
      exec "${REPO_ROOT}/scripts/ubuntu.sh"
    else
      echo "Error: Unsupported Linux distribution: ${DISTRO_ID}" >&2
      echo "Currently supported: Fedora, Ubuntu, and Ubuntu on WSL2." >&2
      echo "Planned support: Arch Linux." >&2
      exit 1
    fi
    ;;
esac
