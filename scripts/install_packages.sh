#!/usr/bin/env bash
###############################################################################
# install_packages.sh
# Install APT packages and CLI tools required for the Coder workspace.
# Sourced from CoderSetupV2.sh package list.
###############################################################################

set -e
set -u

export DEBIAN_FRONTEND=noninteractive

echo ">>> Adding universe repository..."
sudo add-apt-repository universe -y
sudo apt update -y

echo ">>> Installing base APT packages..."
sudo apt install -y \
    btop \
    tree \
    duf \
    tmux \
    curl \
    unzip \
    tar \
    zsh \
    git \
    wget

echo ">>> Installing Neovim prerequisites..."
sudo apt install -y \
    build-essential \
    gcc \
    g++ \
    make \
    ripgrep \
    fd-find \
    nodejs \
    npm \
    python3 \
    python3-pip \
    xclip \
    wl-clipboard

# Create fd symlink (fdfind -> fd) for Neovim Telescope
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    mkdir -p /home/coder/.local/bin
    ln -sf "$(which fdfind)" /home/coder/.local/bin/fd
    echo "[INF] Created symlink fd -> fdfind in ~/.local/bin"
fi

echo ">>> Package installation complete."