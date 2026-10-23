#!/usr/bin/env bash
###############################################################################
# Setup script for root environment (Ubuntu-based)
# - Install Oh-My-Zsh for root user (independent instance)
# - Install custom theme (ngxxfus)
# - Install Oh-My-Zsh plugins (syntax-highlighting, autosuggestions, zsh-z)
# - Configure /root/.zshrc safely
#
# Usage: sudo bash setup/RootOhMyZshSetup.sh
###############################################################################

set -e  # Exit immediately on error
set -u  # Treat unset variables as error

# ===========================================================================
# Global config flags (set to 1 to enable, 0 to skip)
# ===========================================================================
export SETUP_ROOT_OMZ_EN=1
export SETUP_ROOT_THEME_EN=1
export SETUP_ROOT_PLUGINS_EN=1
export SETUP_CONN_CHECK_EN=1

# ===========================================================================
# Global private vars
# ===========================================================================
export FOLDER_ROOT_HOME="/root"
export FOLDER_ROOT_ZSHRC="${FOLDER_ROOT_HOME}/.zshrc"
export FOLDER_ROOT_OMZ="${FOLDER_ROOT_HOME}/.oh-my-zsh"
export FOLDER_ROOT_CUSTOM="${FOLDER_ROOT_OMZ}/custom"
export FOLDER_ROOT_THEMES="${FOLDER_ROOT_CUSTOM}/themes"
export FILE_NGXXFUS_THEME="${FOLDER_ROOT_THEMES}/ngxxfus.zsh-theme"

# URLs
export URL_FORWORK_ROOTDIR="https://raw.githubusercontent.com/ngxx-fus/ForWork/refs/heads/main"
export URL_NGXXFUS_THEME="${URL_FORWORK_ROOTDIR}/.assert/ngxxfus.zsh-theme"
export URL_OHMYZSH_INSTALL_SCRIPT="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
export URL_ZSH_SYNTAX_HIGHLIGHTING_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
export URL_ZSH_AUTOSUGGESTIONS_REPO="https://github.com/zsh-users/zsh-autosuggestions.git"
export URL_ZSH_Z_REPO="https://github.com/agkozak/zsh-z.git"

# ===========================================================================
# Helper functions
# ===========================================================================

MakeThisDirExist() {
    if [[ $# -ne 1 ]]; then
        echo "[ERR][MakeThisDirExist] Wrong number of args (expected 1, got $#)"
        return 1
    fi
    local target_dir="$1"
    if [ -d "${target_dir}" ]; then return 0; fi
    if mkdir -p "${target_dir}"; then
        echo "[INF][MakeThisDirExist] Created: '${target_dir}'"
        return 0
    else
        echo "[ERR][MakeThisDirExist] Failed to create: '${target_dir}'"
        return 1
    fi
}

AppendIfNotExist() {
    if [[ $# -ne 2 ]]; then
        echo "[ERR][AppendIfNotExist] Wrong number of args (expected 2, got $#)"
        return 1
    fi
    local target_file="$1"
    local line="$2"
    if ! grep -qF "${line}" "${target_file}" 2>/dev/null; then
        echo "${line}" >> "${target_file}"
        echo "[INF][AppendIfNotExist] Appended to ${target_file}: ${line}"
    else
        echo "[INF][AppendIfNotExist] Already exists, skipping: ${line}"
    fi
}

PerformConnectionCheck() {
    if [[ $# -ne 1 ]]; then
        echo "[ERR][PerformConnectionCheck] Missing URL argument."
        return 1
    fi
    local target_url="$1"
    if [[ "${SETUP_CONN_CHECK_EN}" != "1" ]]; then return 0; fi
    echo "[INF][PerformConnectionCheck] Testing connection to: ${target_url}"
    if curl --output /dev/null --silent --head --fail --location "${target_url}"; then
        echo "[INF][PerformConnectionCheck] Connection OK."
        return 0
    else
        return 1
    fi
}

# ===========================================================================
# Pre-flight Checks
# ===========================================================================
echo ">>> Running pre-flight checks..."

if [[ "${EUID}" -ne 0 ]]; then
    echo "[ERR] This script must be executed as root. Please run with sudo or as root user."
    exit 1
fi

for pkg in git curl zsh; do
    if ! command -v "${pkg}" >/dev/null 2>&1; then
        echo "[ERR] Missing prerequisite: ${pkg}. Please run: apt install ${pkg}"
        exit 1
    fi
done

# ===========================================================================
# Clean Insecure Symlinks (Fix compaudit issue)
# ===========================================================================
if [ -L "${FOLDER_ROOT_OMZ}" ]; then
    echo "[WARN] Detected symlinked ${FOLDER_ROOT_OMZ} pointing to user directory."
    echo "[INF] Removing insecure symlink to prevent compaudit security blocks..."
    rm -f "${FOLDER_ROOT_OMZ}"
fi

# ===========================================================================
# Install Oh-My-Zsh for Root
# ===========================================================================
if [[ "${SETUP_ROOT_OMZ_EN}" == "1" ]]; then
    echo ">>> Initializing Oh-My-Zsh for root..."

    if [ -d "${FOLDER_ROOT_OMZ}" ] && [ ! -d "${FOLDER_ROOT_OMZ}/.git" ]; then
        mv "${FOLDER_ROOT_OMZ}" "${FOLDER_ROOT_OMZ}.bak.$(date +%s)"
        echo "[INF] Backed up old /root/.oh-my-zsh directory"
    fi

    if [ -f "${FOLDER_ROOT_ZSHRC}" ]; then
        cp -vf "${FOLDER_ROOT_ZSHRC}" "${FOLDER_ROOT_ZSHRC}.bak"
        echo "[INF] Backed up /root/.zshrc -> /root/.zshrc.bak"
    fi

    if [ ! -d "${FOLDER_ROOT_OMZ}" ]; then
        final_url="${URL_OHMYZSH_INSTALL_SCRIPT}"
        if ! PerformConnectionCheck "${final_url}"; then
            echo "[ERR] Failed to connect to ${final_url}. Aborting."
            exit 1
        fi
        echo "[INF] Running unattended Oh-My-Zsh installer for root..."
        ZSH="${FOLDER_ROOT_OMZ}" sh -c "$(curl -fsSL ${final_url})" "" --unattended
    else
        echo "[INF] Oh-My-Zsh already installed at ${FOLDER_ROOT_OMZ}."
    fi
fi

# ===========================================================================
# Install Plugins
# ===========================================================================
if [[ "${SETUP_ROOT_PLUGINS_EN}" == "1" ]]; then
    echo ">>> Setting up plugins for root..."

    MakeThisDirExist "${FOLDER_ROOT_CUSTOM}/plugins"

    if [ ! -d "${FOLDER_ROOT_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
        echo "[INF] Cloning zsh-syntax-highlighting..."
        git clone "${URL_ZSH_SYNTAX_HIGHLIGHTING_REPO}" "${FOLDER_ROOT_CUSTOM}/plugins/zsh-syntax-highlighting"
    fi

    if [ ! -d "${FOLDER_ROOT_CUSTOM}/plugins/zsh-autosuggestions" ]; then
        echo "[INF] Cloning zsh-autosuggestions..."
        git clone "${URL_ZSH_AUTOSUGGESTIONS_REPO}" "${FOLDER_ROOT_CUSTOM}/plugins/zsh-autosuggestions"
    fi

    if [ ! -d "${FOLDER_ROOT_CUSTOM}/plugins/zsh-z" ]; then
        echo "[INF] Cloning zsh-z..."
        git clone "${URL_ZSH_Z_REPO}" "${FOLDER_ROOT_CUSTOM}/plugins/zsh-z"
    fi

    if [ -f "${FOLDER_ROOT_ZSHRC}" ]; then
        sed -i \
            's/^plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-z)/' \
            "${FOLDER_ROOT_ZSHRC}"
    fi
fi

# ===========================================================================
# Install ngxxfus Custom Theme
# ===========================================================================
if [[ "${SETUP_ROOT_THEME_EN}" == "1" ]]; then
    echo ">>> Downloading and configuring ngxxfus theme for root..."

    MakeThisDirExist "${FOLDER_ROOT_THEMES}"

    theme_url="${URL_NGXXFUS_THEME}"
    if ! PerformConnectionCheck "${theme_url}"; then
        echo "[ERR] Failed to connect to ${theme_url}. Skipping custom theme."
    else
        echo "[INF] Downloading theme to ${FILE_NGXXFUS_THEME}..."
        curl -fsSL "${theme_url}" -o "${FILE_NGXXFUS_THEME}"
        chmod 644 "${FILE_NGXXFUS_THEME}"
        if grep -q '^ZSH_THEME=' "${FOLDER_ROOT_ZSHRC}"; then
            sed -i 's/^ZSH_THEME=.*/ZSH_THEME="ngxxfus"/' "${FOLDER_ROOT_ZSHRC}"
        else
            AppendIfNotExist "${FOLDER_ROOT_ZSHRC}" 'ZSH_THEME="ngxxfus"'
        fi
        echo "[INF] Set ZSH_THEME=\"ngxxfus\" in ${FOLDER_ROOT_ZSHRC}"
    fi
fi

# ===========================================================================
# Ownership & Security Fix
# ===========================================================================
echo ">>> Enforcing strict permissions on root directories..."
chown -R root:root "${FOLDER_ROOT_OMZ}" "${FOLDER_ROOT_ZSHRC}"
chmod 700 "${FOLDER_ROOT_OMZ}"
chmod 600 "${FOLDER_ROOT_ZSHRC}"

# ===========================================================================
# Goodbye
# ===========================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════════╗"
echo "║                        Root Oh-My-Zsh Setup Complete!                            ║"
echo "║                                                                                  ║"
echo "║  Test it now by running:                                                         ║"
echo "║      sudo su                                                                     ║"
echo "║      source /root/.zshrc                                                         ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════╝"