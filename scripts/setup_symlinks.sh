#!/usr/bin/env bash
###############################################################################
# setup_symlinks.sh
# Symlink dotfiles packages into the correct locations using GNU stow.
# Target user: coder (/home/coder)
###############################################################################

set -e
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "${SCRIPT_DIR}")"
TARGET_HOME="/home/coder"

# ---------------------------------------------------------------------------
# Install stow if not present
# ---------------------------------------------------------------------------
if ! command -v stow >/dev/null 2>&1; then
    echo "[INF] stow not found. Installing..."
    sudo apt install -y stow
fi

cd "${DOTFILES_DIR}"

# ---------------------------------------------------------------------------
# Helper: stow a package safely (restow if already linked)
# ---------------------------------------------------------------------------
stow_package() {
    local pkg="$1"
    if [ ! -d "${DOTFILES_DIR}/${pkg}" ]; then
        echo "[WARN] Package '${pkg}' not found. Skipping."
        return 0
    fi
    echo "[INF] Stowing '${pkg}' -> ${TARGET_HOME}"
    stow --restow --target="${TARGET_HOME}" --dir="${DOTFILES_DIR}" "${pkg}"
}

# ---------------------------------------------------------------------------
# Stow each package
# ---------------------------------------------------------------------------
stow_package "zsh"
stow_package "git"
stow_package "tmux"
stow_package "bin"

# nvim: target is ~/.config/nvim (already structured under nvim/.config/nvim/)
stow_package "nvim"

# bspwm: only stow on non-Coder local machines (skip in headless/Coder env)
if [[ -z "${CODER_WORKSPACE_NAME:-}" ]]; then
    stow_package "bspwm"
else
    echo "[INF] Coder workspace detected. Skipping bspwm (headless environment)."
fi

echo ">>> Symlinks setup complete."