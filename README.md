# Dotfiles

Personal dotfiles managed with GNU Stow. Each top-level directory is a Stow
package whose contents map directly into `$HOME`.

## Layout

- `zsh`, `fish`, `tmux`, `nvim`, `ghostty`, `kitty`, `alacritty`, `wezterm`, and `zellij` manage shell, editor, terminal, and multiplexer config.
- `niri`, `waybar`, `kanshi`, `fuzzel`, `hyprlock`, `swayosd`, `sway`, `i3`, `picom`, `polybar`, `rofi`, `sworkstyle`, and `workstyle` manage desktop/session config.
- `systemd` contains user services that are not shipped by their packages.
- `scripts` installs helper scripts under `~/.local/scripts`.
- `packages` contains package and user-service manifests consumed by `setup.sh`.

## Bootstrap

On Arch Linux, run:

```sh
./setup.sh
```

Useful options:

```sh
./setup.sh --noconfirm
./setup.sh --stow
./setup.sh --skip-packages
./setup.sh --skip-services
```

The setup script:

- installs `yay-bin` if `yay` is missing;
- installs `packages/pacman.txt` with `pacman`;
- installs `packages/aur.txt` with `yay`;
- prints entries from `packages/local.txt` because they are local or private packages;
- links repo-managed user units from `systemd/.config/systemd/user`;
- disables stale or conflicting units from `packages/user-services-disabled.txt`;
- enables and starts units from `packages/user-services.txt` when the user graphical session is active;
- creates an ignored Niri local config from the example if one does not exist.

`--stow` restows every top-level package into `$HOME`, except `packages` and
`systemd`. User systemd units are linked separately so
`~/.config/systemd/user` remains a real directory for `systemctl --user` state
such as `*.target.wants` directories. Before restowing, existing package-owned
target directories such as `~/.config/nvim` are moved into
`~/.dotfiles.bak/<timestamp>` so Stow can replace them with symlinks. Existing
target files are still left for Stow to report as conflicts.

## Niri Local Config

The tracked Niri config includes `config.local.kdl`:

```kdl
include "config.local.kdl"
```

`niri/.config/niri/config.local.kdl` is ignored by Git. Put monitor names,
serials, output positions, and other device-specific Niri settings there.
Use `niri/.config/niri/config.local.kdl.example` as the template.

## Fish

Fish config, completions, functions, themes, and the `fish_plugins` manifest are
tracked. `fish_variables*` is intentionally ignored because Fish universal
variables are machine-local state.

## User Services

The intended user-managed desktop services are listed in
`packages/user-services.txt`. This includes `waybar`, `kanshi`, `swayosd-server`,
`swaync`, audio services, and session helpers.

`mako.service` is disabled because `swaync.service` owns notifications. Stale
local units such as `elephant.service` are also disabled by setup.

## Validation

Common checks after edits:

```sh
bash -n setup.sh
shellcheck setup.sh
niri validate --config niri/.config/niri/config.kdl
jq . waybar/.config/waybar/config.jsonc >/dev/null
ghostty +validate-config --config-file=ghostty/.config/ghostty/config
systemd-analyze --user verify systemd/.config/systemd/user/*.service
```

For Fish files:

```sh
for file in fish/.config/fish/**/*.fish fish/.config/fish/config.fish; do
  fish --no-config --no-execute "$file"
done
```

Use `git diff --no-ext-diff` when reviewing changes.
