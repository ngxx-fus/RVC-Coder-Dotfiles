# dotfiles

Personal dotfiles and setup scripts for Coder workspace (Ubuntu-based).
Target user: `coder` (`/home/coder`)

## Structure

```
dotfiles/
├── .gitignore
├── README.md
├── install.sh                  # Entrypoint: packages + CoderSetupV2 + symlinks
│
├── setup/                      # Full setup scripts
│   ├── CoderSetupV2.sh         # Main Coder setup (nvim, omz, clangd, jlink, fonts...)
│   ├── UbuntuSetup.sh          # Ubuntu personal machine setup
│   └── RootOhMyZshSetup.sh     # Root user Oh-My-Zsh setup
│
├── scripts/                    # Helper scripts
│   ├── install_packages.sh     # APT packages + CLI tools
│   └── setup_symlinks.sh       # GNU stow symlinks
│
├── zsh/                        # stow -> ~/.zshrc
│   └── .zshrc
│
├── git/                        # stow -> ~/.gitconfig, ~/.gitignore_global
│   ├── .gitconfig
│   └── .gitignore_global
│
├── nvim/                       # stow -> ~/.config/nvim
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── lua/
│               ├── config/
│               │   ├── options.lua
│               │   ├── keymaps.lua
│               │   └── lazy.lua
│               └── plugins/
│                   └── init.lua
│
├── tmux/                       # stow -> ~/.tmux.conf
│   └── .tmux.conf
│
├── bspwm/                      # stow -> ~/.config/bspwm, ~/.config/sxhkd (local only)
│   └── .config/
│       ├── bspwm/
│       │   └── bspwmrc
│       └── sxhkd/
│           └── sxhkdrc
│
└── bin/                        # stow -> ~/.local/bin
    └── .local/
        └── bin/
            └── my_script
```

## Quick Start (Coder workspace)

```bash
git clone https://github.com/ngxx-fus/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

## Individual scripts

| Script | Usage | Target |
|---|---|---|
| `install.sh` | `bash install.sh` | Coder workspace entrypoint |
| `setup/CoderSetupV2.sh` | `bash setup/CoderSetupV2.sh` | Coder `/home/coder` |
| `setup/UbuntuSetup.sh` | `bash setup/UbuntuSetup.sh` | Ubuntu `/home/fus` |
| `setup/RootOhMyZshSetup.sh` | `sudo bash setup/RootOhMyZshSetup.sh` | `/root` |
| `scripts/setup_symlinks.sh` | `bash scripts/setup_symlinks.sh` | stow all packages |

## What gets installed (CoderSetupV2.sh)

| Component | Path | Note |
|---|---|---|
| Zsh | system | Set as default shell |
| Oh-My-Zsh | `~/.oh-my-zsh` | + ngxxfus theme |
| Plugins | `~/.oh-my-zsh/custom/plugins/` | syntax-highlighting, autosuggestions, zsh-z |
| Neovim nightly | `/opt/nvim` → `/usr/local/bin/nvim` | |
| Neovim config | `~/.config/nvim` | cloned from ngxx-fus/neovim-conf |
| Clangd 22.1.6 | `/opt/clangd` → `/usr/bin/clangd` | |
| JLink V970 x86 | `~/workspace/JLink_V970` | |
| JLink V970 ARM | `~/workspace/JLink_V970_Arm` | |
| JLink V950 x86 | `~/workspace/JLink_V950` | |
| JLink V950 ARM | `~/workspace/JLink_V950_Arm` | |
| Nerd Fonts | `~/.local/share/fonts/NerdFonts/` | ~1.5GB full pack |
| User aliases | `~/.fus/user_aliases.sh` | |
| Wallpaper | `~/.fus/.BG/` | |
| Timezone | `Asia/Ho_Chi_Minh` | HCMC |

## stow packages

| Package | Symlink target |
|---|---|
| `zsh` | `~/.zshrc` |
| `git` | `~/.gitconfig`, `~/.gitignore_global` |
| `nvim` | `~/.config/nvim/` |
| `tmux` | `~/.tmux.conf` |
| `bin` | `~/.local/bin/` |
| `bspwm` | `~/.config/bspwm/`, `~/.config/sxhkd/` (local only) |

> **Note:** `bspwm` is skipped automatically in Coder workspace (headless environment).