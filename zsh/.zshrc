# ===========================================================================
# .zshrc - Base template for ngxxfus/coder environment
# Managed by dotfiles (stow: zsh/.zshrc -> ~/.zshrc)
# ===========================================================================

# Path to Oh-My-Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="ngxxfus"

# Plugins
plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-z)

source $ZSH/oh-my-zsh.sh

# ===========================================================================
# PATH additions
# ===========================================================================
export PATH="$HOME/.local/bin:$PATH"          # fd symlink (fdfind -> fd)
export PATH="/opt/nvim/bin:$PATH"             # Neovim
export PATH="/opt/clangd/bin:$PATH"           # Clangd
export PATH="/usr/local/bin:$PATH"            # General local binaries

# ===========================================================================
# JLink tools (added by CoderSetupV2.sh)
# ===========================================================================
# JLINK JLink_V970 ###################################
export PATH="$PATH:/home/coder/workspace/JLink_V970"
# JLINK JLink_V970_Arm ###################################
# export PATH="$PATH:/home/coder/workspace/JLink_V970_Arm"
# JLINK JLink_V950 ###################################
# export PATH="$PATH:/home/coder/workspace/JLink_V950"
# JLINK JLink_V950_Arm ###################################
# export PATH="$PATH:/home/coder/workspace/JLink_V950_Arm"

# ===========================================================================
# User aliases
# ===========================================================================
# User aliases
source $HOME/.fus/user_aliases.sh