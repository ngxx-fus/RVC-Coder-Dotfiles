#!/usr/bin/env bash
###############################################################################
# Setup script for personal workspace (Ubuntu-based)
# - Install Neovim + custom config
# - Install Oh-My-Zsh + plugins + custom theme
# - Install user aliases
# - Setup desktop background wallpaper
# - Install Clangd
# - Install custom APT packages
# - Install IBus Bamboo
#
# Usage: bash setup/UbuntuSetup.sh
###############################################################################

set -e  # Exit immediately on error
set -u  # Treat unset variables as error

# ===========================================================================
# Global config flags (set to 1 to enable, 0 to skip)
# ===========================================================================
export SETUP_OHMYZSH_EN=1
export SETUP_NVIM_EN=1
export SETUP_NVIM_PREREQUISITES_EN=1        # only works if SETUP_NVIM_EN=1
export SETUP_ADD_APT_REPO_EN=1
export SETUP_USER_ALIASES_EN=1
export SETUP_BACKGROUND_EN=1
export SETUP_AUTO_SET_BACKGROUND_EN=0       # only works if SETUP_BACKGROUND_EN=1
export SETUP_CLANGD_EN=1
export SETUP_BAMBOO_IBUS_EN=1

export SETUP_CONN_CHECK_EN=1
export SETUP_VALID_FILE_CHECK_FILE_EN=0     # temporarily not implemented/active

export SETUP_APT_INSTALL_LIST_EN=1
export SETUP_APT_INSTALL_LIST=(
    "wget" "curl" "htop" "neofetch" "btop" "tree" "duf" "tmux" "zsh" "git"
)

# ===========================================================================
# Global private vars
# ===========================================================================
export NVIM_VERSION="nightly"
export NVIM_TARBALL="nvim-linux-x86_64.tar.gz"
export NIVM_INSTALL_DIRNAME="nvim-linux-x86_64"
export BACKGROUND_IMG_FILENAME="IMG_4273.JPG"
export CLANGD_VERSION="22.1.6"
export CLANGD_ZIP_FILENAME="clangd-linux-22.1.6.zip"
export CLANGD_EXTRACTED_FILENAME="clangd_22.1.6"

export FOLDER_CURRENT=$(pwd)
export FOLDER_HOME="/home/fus"
export FOLDER_WORKSPACE="${FOLDER_HOME}/workspace"
export FOLDER_DOWNLOADS="${FOLDER_HOME}/Downloads"
export FOLDER_DOT_ZSHRC="${FOLDER_HOME}/.zshrc"
export FOLDER_DOT_OH_MY_ZSH="${FOLDER_HOME}/.oh-my-zsh"
export FOLDER_NVIM_CONFIG="${FOLDER_HOME}/.config/nvim"
export FOLDER_FUS="${FOLDER_HOME}/.fus"
export FOLDER_BACKGROUND="${FOLDER_FUS}/.BG"
export FILE_USER_ALIASES="${FOLDER_FUS}/user_aliases.sh"
export FOLDER_CLANGD="/opt/clangd"
export FOLDER_OMZ_THEMES="${FOLDER_DOT_OH_MY_ZSH}/themes"
export FILE_NGXXFUS_THEME="${FOLDER_OMZ_THEMES}/ngxxfus.zsh-theme"

# URLs
export URL_FORWORK_ROOTDIR="https://raw.githubusercontent.com/ngxx-fus/ForWork/refs/heads/main"
export URL_USER_ALIASES="${URL_FORWORK_ROOTDIR}/.assert/useralias.sh"
export URL_NGXXFUS_THEME="${URL_FORWORK_ROOTDIR}/.assert/ngxxfus.zsh-theme"
export URL_BACKGROUND_IMG="${URL_FORWORK_ROOTDIR}/.imgs/BG/IMG_4273.JPG"
export URL_NVIM_DOWNLOAD="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TARBALL}"
export URL_NEOVIM_CONF_REPO="https://github.com/ngxx-fus/neovim-conf.git"
export URL_OHMYZSH_INSTALL_SCRIPT="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
export URL_ZSH_SYNTAX_HIGHLIGHTING_REPO="https://github.com/zsh-users/zsh-syntax-highlighting.git"
export URL_ZSH_AUTOSUGGESTIONS_REPO="https://github.com/zsh-users/zsh-autosuggestions.git"
export URL_ZSH_Z_REPO="https://github.com/agkozak/zsh-z.git"
export URL_CLANGD="https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/${CLANGD_ZIP_FILENAME}"

# ===========================================================================
# User Confirmation Prompt
# ===========================================================================
echo "================================================================================"
echo "                     INSTALLATION PATH CONFIGURATION CHECK                      "
echo "================================================================================"
echo " Please verify the following target directories and paths:"
echo ""
echo "  [User Home]         : ${FOLDER_HOME}"
echo "  [Workspace]         : ${FOLDER_WORKSPACE}"
echo "  [Downloads]         : ${FOLDER_DOWNLOADS}"
echo "  [Zsh RC]            : ${FOLDER_DOT_ZSHRC}"
echo "  [Oh-My-Zsh]         : ${FOLDER_DOT_OH_MY_ZSH}"
echo "  [Neovim Config]     : ${FOLDER_NVIM_CONFIG}"
echo "  [Custom Assets]     : ${FOLDER_FUS}"
echo "  [Wallpapers]        : ${FOLDER_BACKGROUND}"
echo "  [User Aliases File] : ${FILE_USER_ALIASES}"
echo "  [Clangd Target]     : ${FOLDER_CLANGD}"
echo "================================================================================"
read -r -p "Do you want to continue with these paths? [y/N]: " user_choice

case "${user_choice}" in
    [yY]|[yY][eE][sS])
        echo "[INF] Paths confirmed. Proceeding with setup..."
        ;;
    *)
        echo "[WARN] Setup cancelled by user. Exiting."
        exit 0
        ;;
esac

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

PerformDownloadCheck() {
    if [[ $# -ne 1 ]]; then
        echo "[ERR][PerformDownloadCheck] Missing URL argument."
        return 1
    fi
    local target_url="$1"
    if [[ "${SETUP_VALID_FILE_CHECK_FILE_EN}" != "1" ]]; then return 0; fi
    echo "[INF][PerformDownloadCheck] Validating file type for: ${target_url}"
    local content_type
    content_type=$(curl -sI -L "${target_url}" | grep -i -E "^Content-Type:" | tail -n 1)
    if echo "${content_type}" | grep -q -i "text/html"; then
        echo "[ERR][PerformDownloadCheck] URL returned HTML instead of a valid file!"
        return 1
    else
        echo "[INF][PerformDownloadCheck] File format OK."
        return 0
    fi
}

# ===========================================================================
# Pre-flight Checks
# ===========================================================================
echo ">>> Running pre-flight checks..."
if ! sudo -n true 2>/dev/null; then
    echo "[ERR] Sudo requires a password. Please run in an environment with passwordless sudo."
    exit 1
fi

# ===========================================================================
# Pre-create required directories
# ===========================================================================
MakeThisDirExist "${FOLDER_CURRENT}"
MakeThisDirExist "$(dirname "${FOLDER_DOT_ZSHRC}")"
MakeThisDirExist "${FOLDER_DOWNLOADS}"
MakeThisDirExist "${FOLDER_FUS}"

# ===========================================================================
# Add repository & Install APT Packages
# ===========================================================================
if [[ "${SETUP_ADD_APT_REPO_EN}" == "1" ]]; then
    echo ">>> Updating apt repositories..."
    export DEBIAN_FRONTEND=noninteractive
    sudo add-apt-repository universe -y
    sudo apt update -y
fi

if [[ "${SETUP_APT_INSTALL_LIST_EN}" == "1" ]]; then
    echo ">>> Installing custom APT packages..."
    export DEBIAN_FRONTEND=noninteractive
    sudo apt install -y "${SETUP_APT_INSTALL_LIST[@]}"
fi

# ===========================================================================
# Install Neovim
# ===========================================================================
if [[ "${SETUP_NVIM_EN}" == "1" ]]; then
    echo ">>> Installing Neovim (${NVIM_VERSION})..."
    final_url="${URL_NVIM_DOWNLOAD}"
    if ! PerformConnectionCheck "${final_url}"; then
        echo "[ERR] Failed to connect to ${final_url}. Skipping Neovim."
    elif ! PerformDownloadCheck "${final_url}"; then
        echo "[ERR] Invalid file format at ${final_url}. Skipping Neovim."
    else
        if [[ "${SETUP_NVIM_PREREQUISITES_EN}" == "1" ]]; then
            echo "[INF] Installing Neovim prerequisites..."
            export DEBIAN_FRONTEND=noninteractive
            sudo apt update && sudo apt install -y \
                git build-essential gcc g++ make ripgrep fd-find \
                unzip curl tar nodejs npm python3 python3-pip xclip wl-clipboard
            MakeThisDirExist "${FOLDER_HOME}/.local/bin"
            if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
                ln -sf "$(which fdfind)" "${FOLDER_HOME}/.local/bin/fd"
                echo "[INF] Created symlink for fd -> fdfind in ~/.local/bin"
            fi
        fi
        cd "${FOLDER_DOWNLOADS}"
        wget -q --show-progress "${final_url}" -O "${NVIM_TARBALL}"
        tar -zxvf "${NVIM_TARBALL}"
        if [ -d /opt/nvim ]; then
            sudo cp -vrf /opt/nvim "/opt/nvim.bak.$(date +%s)"
            sudo rm -rf /opt/nvim
        fi
        if [ -e /usr/local/bin/nvim ]; then sudo rm -vf /usr/local/bin/nvim; fi
        sudo mkdir -p /opt/nvim
        sudo cp -vrf "${NIVM_INSTALL_DIRNAME}/." /opt/nvim
        sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
        echo "[INF] Created symlink /usr/local/bin/nvim -> /opt/nvim/bin/nvim"
        if [ -d "${FOLDER_NVIM_CONFIG}" ]; then
            mv "${FOLDER_NVIM_CONFIG}" "${FOLDER_NVIM_CONFIG}.bak.$(date +%s)"
        fi
        MakeThisDirExist "${FOLDER_NVIM_CONFIG}"
        git clone --recurse-submodules "${URL_NEOVIM_CONF_REPO}" "${FOLDER_NVIM_CONFIG}"
        rm -rf "${NVIM_TARBALL}" "./${NIVM_INSTALL_DIRNAME}"
        cd "${FOLDER_CURRENT}"
        echo ">>> Neovim installed successfully."
    fi
fi

# ===========================================================================
# Install Oh-My-Zsh + plugins + custom theme
# ===========================================================================
if [[ "${SETUP_OHMYZSH_EN}" == "1" ]]; then
    echo ">>> Installing Oh-My-Zsh..."
    if [ -d "${FOLDER_DOT_OH_MY_ZSH}" ]; then
        mv "${FOLDER_DOT_OH_MY_ZSH}" "${FOLDER_DOT_OH_MY_ZSH}.bak.$(date +%s)"
    fi
    if [ -f "${FOLDER_DOT_ZSHRC}" ]; then
        cp -vf "${FOLDER_DOT_ZSHRC}" "${FOLDER_DOT_ZSHRC}.bak"
    fi
    final_url="${URL_OHMYZSH_INSTALL_SCRIPT}"
    if ! PerformConnectionCheck "${final_url}"; then
        echo "[ERR] Failed to connect to ${final_url}. Skipping Oh-My-Zsh."
    elif ! PerformDownloadCheck "${final_url}"; then
        echo "[ERR] Invalid file format at ${final_url}. Skipping Oh-My-Zsh."
    else
        OMZ_INSTALLER="${FOLDER_DOWNLOADS}/omz_install.sh"
        curl -fsSL "${final_url}" -o "${OMZ_INSTALLER}"
        sh "${OMZ_INSTALLER}" "" --unattended
        export ZSH_CUSTOM="${FOLDER_DOT_OH_MY_ZSH}/custom"
        if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
            git clone "${URL_ZSH_SYNTAX_HIGHLIGHTING_REPO}" "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
        fi
        if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
            git clone "${URL_ZSH_AUTOSUGGESTIONS_REPO}" "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
        fi
        if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-z" ]; then
            git clone "${URL_ZSH_Z_REPO}" "${ZSH_CUSTOM}/plugins/zsh-z"
        fi
        sed -i \
            's/^plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-z)/' \
            "${FOLDER_DOT_ZSHRC}"
        echo ">>> Installing ngxxfus theme..."
        MakeThisDirExist "${FOLDER_OMZ_THEMES}"
        theme_url="${URL_NGXXFUS_THEME}"
        if ! PerformConnectionCheck "${theme_url}"; then
            echo "[ERR] Failed to connect to ${theme_url}. Skipping theme."
        elif ! PerformDownloadCheck "${theme_url}"; then
            echo "[ERR] Invalid file format at ${theme_url}. Skipping theme."
        else
            wget -q --show-progress -O "${FILE_NGXXFUS_THEME}" "${theme_url}"
            if grep -q '^ZSH_THEME=' "${FOLDER_DOT_ZSHRC}"; then
                sed -i 's/^ZSH_THEME=.*/ZSH_THEME="ngxxfus"/' "${FOLDER_DOT_ZSHRC}"
            else
                AppendIfNotExist "${FOLDER_DOT_ZSHRC}" 'ZSH_THEME="ngxxfus"'
            fi
        fi
        if [ -f "${FOLDER_DOT_ZSHRC}.bak" ]; then
            printf "\n\n\n#### ORIGINAL .ZSHRC ####\n\n\n" >> "${FOLDER_DOT_ZSHRC}"
            cat "${FOLDER_DOT_ZSHRC}.bak" >> "${FOLDER_DOT_ZSHRC}"
        fi
        sed -i 's/^autoload -Uz promptinit/# autoload -Uz promptinit/' "${FOLDER_DOT_ZSHRC}"
        sed -i 's/^promptinit/# promptinit/' "${FOLDER_DOT_ZSHRC}"
        sed -i 's/^prompt adam1/# prompt adam1/' "${FOLDER_DOT_ZSHRC}"
    fi
fi

# ===========================================================================
# Install user aliases
# ===========================================================================
if [[ "${SETUP_USER_ALIASES_EN}" == "1" ]]; then
    echo ">>> Installing user aliases..."
    MakeThisDirExist "${FOLDER_FUS}"
    final_url="${URL_USER_ALIASES}"
    if ! PerformConnectionCheck "${final_url}"; then
        echo "[ERR] Failed to connect to ${final_url}. Skipping user aliases."
    elif ! PerformDownloadCheck "${final_url}"; then
        echo "[ERR] Invalid file format at ${final_url}. Skipping user aliases."
    else
        wget -q --show-progress -O "${FILE_USER_ALIASES}" "${final_url}"
        chmod +x "${FILE_USER_ALIASES}"
        AppendIfNotExist "${FOLDER_DOT_ZSHRC}" ""
        AppendIfNotExist "${FOLDER_DOT_ZSHRC}" "# User aliases"
        AppendIfNotExist "${FOLDER_DOT_ZSHRC}" "source ${FILE_USER_ALIASES}"
        echo ">>> User aliases installed successfully."
    fi
fi

# ===========================================================================
# Install Background image
# ===========================================================================
if [[ "${SETUP_BACKGROUND_EN}" == "1" ]]; then
    echo ">>> Setting up desktop background..."
    MakeThisDirExist "${FOLDER_BACKGROUND}"
    cd "${FOLDER_DOWNLOADS}"
    final_url="${URL_BACKGROUND_IMG}"
    if ! PerformConnectionCheck "${final_url}"; then
        echo "[ERR] Failed to connect to ${final_url}. Skipping background."
    elif ! PerformDownloadCheck "${final_url}"; then
        echo "[ERR] Invalid file format at ${final_url}. Skipping background."
    else
        BACKGROUND_DEST_IMG="IMG.$(date "+%H.%M.%S").${BACKGROUND_IMG_FILENAME}"
        FULL_BG_PATH="${FOLDER_BACKGROUND}/${BACKGROUND_DEST_IMG}"
        wget -q --show-progress "${final_url}" -O "${BACKGROUND_DEST_IMG}"
        if [ -f "${BACKGROUND_DEST_IMG}" ]; then
            sudo mkdir -p "/usr/share/backgrounds/xfce"
            sudo cp -v "${BACKGROUND_DEST_IMG}" "/usr/share/backgrounds/xfce/${BACKGROUND_DEST_IMG}"
            sudo chmod 644 "/usr/share/backgrounds/xfce/${BACKGROUND_DEST_IMG}"
            mv -f "${BACKGROUND_DEST_IMG}" "${FULL_BG_PATH}"
            if [[ "${SETUP_AUTO_SET_BACKGROUND_EN}" == "1" ]]; then
                if command -v gsettings >/dev/null 2>&1; then
                    dbus-run-session gsettings set org.gnome.desktop.background picture-uri "file://${FULL_BG_PATH}" 2>/dev/null || true
                    dbus-run-session gsettings set org.gnome.desktop.background picture-uri-dark "file://${FULL_BG_PATH}" 2>/dev/null || true
                fi
            fi
        else
            echo "[ERR] Failed to download background image."
        fi
    fi
    cd "${FOLDER_CURRENT}"
fi

# ===========================================================================
# Install Clangd
# ===========================================================================
if [[ "${SETUP_CLANGD_EN}" == "1" ]]; then
    echo ">>> Installing Clangd (${CLANGD_VERSION})..."
    cd "${FOLDER_DOWNLOADS}"
    final_url="${URL_CLANGD}"
    if ! PerformConnectionCheck "${final_url}"; then
        echo "[ERR] Failed to connect to ${final_url}. Skipping Clangd."
    elif ! PerformDownloadCheck "${final_url}"; then
        echo "[ERR] Invalid file format at ${final_url}. Skipping Clangd."
    else
        wget -q --show-progress "${final_url}" -O "${CLANGD_ZIP_FILENAME}"
        if [ -f "${CLANGD_ZIP_FILENAME}" ]; then
            unzip -q "${CLANGD_ZIP_FILENAME}"
            if [ -d "${CLANGD_EXTRACTED_FILENAME}" ]; then
                if [ -d "${FOLDER_CLANGD}" ]; then
                    sudo mv "${FOLDER_CLANGD}" "${FOLDER_CLANGD}.bak.$(date +%s)"
                fi
                sudo mv "${CLANGD_EXTRACTED_FILENAME}" "${FOLDER_CLANGD}"
                sudo ln -sf "${FOLDER_CLANGD}/bin/clangd" /usr/bin/clangd
                rm -f "${CLANGD_ZIP_FILENAME}"
                echo "[INF] Clangd installation successful."
            else
                echo "[ERR] Extracted folder ${CLANGD_EXTRACTED_FILENAME} not found."
            fi
        else
            echo "[ERR] Failed to download Clangd."
        fi
    fi
    cd "${FOLDER_CURRENT}"
fi

# ===========================================================================
# Install IBus Bamboo
# ===========================================================================
if [[ "${SETUP_BAMBOO_IBUS_EN}" == "1" ]]; then
    echo ">>> Installing IBus Bamboo..."
    if [ -f /etc/apt/sources.list.d/antigravity.list ]; then
        sudo rm -f /etc/apt/sources.list.d/antigravity.list
    fi
    export DEBIAN_FRONTEND=noninteractive
    sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo -y
    sudo apt update -y
    sudo apt install -y ibus-bamboo
    ibus restart || true
    echo ">>> IBus Bamboo installed successfully."
fi

# ===========================================================================
# Goodbye
# ===========================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════════╗"
echo "║                               Setup complete!                                    ║"
echo "║                       Run: source ~/.zshrc                                       ║"
echo "║                       Or restart your shell to apply changes                     ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════╝"