# Dotfiles

Personal desktop setup, provisioned with Ansible on **Arch Linux** or
**Ubuntu 26.04 LTS (Resolute Raccoon)**. It produces the same Niri desktop on
both: niri, waybar, kanshi, swayidle + hyprlock, swaync, swayosd, fuzzel,
ghostty running fish (Tide prompt), and Neovim (LazyVim).

## Layout

- `site.yml` is the playbook; `roles/` holds the `packages`, `dotfiles`,
  `agents` and `services` roles.
- `packages/archlinux.yml` and `packages/ubuntu.yml` list what gets installed.
- `group_vars/all.yml` lists linked config packages, Tide settings, and the
  system and user services to enable.
- Each other top-level directory (`fish`, `fuzzel`, `ghostty`, `hyprlock`,
  `kanshi`, `niri`, `nvim`, `swayidle`, `swayosd`, `waybar`) is a config
  package whose `.config/*` entries are linked into `~/.config`.
- `systemd` holds user units that their packages do not ship.
- `system` mirrors `/` for root-owned config, copied into place (not linked)
  and listed in `system_files`: currently `/etc/keyd/default.conf`, which makes
  the Copilot key (Meta+Shift+F23) and the Compose key act as Super.
- `agents` holds coding-agent configs (Claude Code, Codex, t3code, opencode),
  laid out like `$HOME`. `agents/local/` is gitignored, for work-specific bits.
- `Vagrantfile` boots throwaway VMs to test the playbook.

## Bootstrap

Clone the repo (the configs are symlinked from wherever it lives, usually
`~/dotfiles`), install Ansible, then run the playbook as your normal user:

```sh
# Arch
sudo pacman -S --needed ansible git
# Ubuntu
sudo apt install ansible git

ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml --ask-become-pass
```

Tags: `packages`, `dotfiles`, `agents`, `services`. They replace the old
`setup.sh` flags:

```sh
ansible-playbook site.yml -K --tags dotfiles          # only link configs (was --stow)
ansible-playbook site.yml -K --skip-tags packages     # was --skip-packages
ansible-playbook site.yml -K --skip-tags services     # was --skip-services
ansible-playbook site.yml -K --check --diff           # preview
```

Useful variables (`-e name=value`):

- `packages_skip`: names from the package files to leave out, e.g.
  `-e '{"packages_skip": ["ventoy-bin", "brave-browser-release"]}'`.
- `packages_arch_full_upgrade=false`: skip the `pacman -Syu` before installing.
- `dotfiles_dir`: where the repo lives, if not where the playbook is run from.

## What the playbook does

**packages**

- Arch: refreshes the keyring, runs a full upgrade, installs
  `arch_pacman_packages`, builds `yay-bin` if `yay` is missing, and installs
  `arch_aur_packages` with yay. yay needs `sudo pacman` without a prompt, so a
  sudoers rule allowing just that is added for the AUR step and always removed
  afterwards.
- Ubuntu: adds vendor apt repos (Chrome, Brave, VS Code, GitHub CLI, Mozilla
  Firefox, OnlyOffice, DBeaver, Beekeeper Studio) and installs the apt list.
  Tools Ubuntu does not ship come from pinned GitHub/vendor releases unpacked
  into `/opt/dotfiles/<name>/<version>` and linked into `/usr/local/bin`.
  `niri`, `xwayland-satellite`, `wiremix` and `wl-clip-persist` are built
  from source with cargo. The CaskaydiaMono Nerd Font and adw-gtk3 theme are
  installed from their releases, and Zen, Bitwarden and Bruno from Flathub.
  To upgrade a pinned tool, bump its `version` and `url` in
  `packages/ubuntu.yml`.

**dotfiles**

- Links each config package's `.config/*` entries into `~/.config`.
  `~/.config`, `~/.local` and `~/.config/systemd/user` stay real directories
  so applications and `systemctl --user` can write state there; if an old Stow
  run folded them into the repo they are unfolded.
- Existing files or directories in the way are moved to
  `~/.dotfiles.bak/<timestamp>/` first.
- Links the repo's user units from `systemd/.config/systemd/user`.
- Creates the ignored `niri/.config/niri/config.local.kdl` from the example.
- Runs `tide configure` once, if Tide has not been configured.

**agents**

- Installs the agent CLIs per user into `~/.local` so they can update
  themselves: Codex (`@openai/codex`) and opencode (`@opencode/cli`) with npm,
  and Claude Code's native install (bootstrapped once from the checksummed
  release, then self-updating). The desktop apps come from the package step:
  ChatGPT with Codex from OpenAI's repo (pacman on Arch, apt on Ubuntu),
  Claude Desktop (Anthropic's apt repo; the AUR on Arch, which Anthropic does
  not support), and T3 Code (AUR nightly on Arch, its pinned `.deb` on Ubuntu).
- Installs agent configs from `agents/`, matching how each app treats them:
  - linked: Codex skills, opencode `AGENTS.md` and `opencode.jsonc`;
  - merged into the app's JSON (keys the app adds are kept): Claude Code
    `settings.json`, t3code `settings.json` and `client-settings.json`;
  - copied every run (the repo wins): t3code `keybindings.json`;
  - written only if missing, since Codex rewrites it: `~/.codex/config.toml`;
  - `~/.codex/AGENTS.md` is `agents/.codex/AGENTS.md` with
    `agents/local/.codex/AGENTS.md` appended when it exists.
- Any other file under `agents/local/` (gitignored) is linked to the same path
  under `$HOME`, e.g. `agents/local/.codex/rules/work.rules`. Keep work rules,
  internal tool names and similar private details there: this repo is public.
- Credentials, history, sessions and app-generated state (`~/.claude.json`,
  `~/.codex/auth.json`, `~/.codex/rules/default.rules`, ...) are never managed.

**services**

- Installs the `system/` config files, restarting their service when they
  change, and enables keyd.
- Enables the display manager (Plasma Login on Arch, GDM on Ubuntu) and boots
  to `graphical.target`; enables bluetooth, docker, power-profiles-daemon and
  ufw; leaves MariaDB and PostgreSQL installed but stopped; adds you to the
  `docker` and `kvm` groups.
- Logs you straight into niri from the display manager when the root
  filesystem is on an encrypted (LUKS/dm-crypt) device, since the disk
  passphrase at boot already authenticates you. Set `display_autologin` to
  `true` or `false` to override the `auto` detection. On Ubuntu niri also
  becomes your default GDM session.
- Disables stale user units (`mako`, `hypridle`, `elephant`) and enables the
  session units in `user_services`. They start immediately inside a graphical
  session, otherwise at the next login.

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
tracked (plugins are vendored, so Fisher does not need to run).
`fish_variables*` is intentionally ignored because Fish universal variables are
machine-local state.

## Waybar Codex Usage

The Waybar Codex module shows the percentage of the most constrained usage
window that remains. Its tooltip lists each available window and reset time.
It refreshes through the signed-in Codex CLI every five minutes and falls back
to a clearly marked cached value if a live refresh fails.

## Testing in a VM

The `Vagrantfile` defines VirtualBox VMs that rsync this repo to
`~/dotfiles` and run the playbook against it:

```sh
vagrant up ubuntu                 # create and provision Ubuntu 26.04
vagrant provision ubuntu          # second run: expect changed=0
vagrant up arch                   # same for Arch
```

The `archlinux/archlinux` box is from 2024; its first boot runs a `bootstrap`
provisioner that upgrades it and installs Python and rsync. Its own rsync is
broken until then, so on the very first `vagrant up arch` the folder sync can
fail: run `vagrant provision arch --provision-with bootstrap`, then
`vagrant reload arch --provision`.

Niri cannot render on VirtualBox's virtual GPU (it rejects software EGL), so
the session starts but the screen stays on the console. To see the desktop,
boot the VM disk in QEMU with `-device virtio-vga-gl -display egl-headless`.

Extra variables for the VM run can be passed as JSON:

```sh
DOTFILES_EXTRA_VARS='{"packages_skip": ["ventoy-bin"]}' vagrant provision ubuntu
```

## Validation

Common checks after edits:

```sh
ansible-playbook site.yml --syntax-check
ansible-lint site.yml
niri validate --config niri/.config/niri/config.kdl
jq . waybar/.config/waybar/config.jsonc >/dev/null
shellcheck waybar/.config/waybar/scripts/codex-usage
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
