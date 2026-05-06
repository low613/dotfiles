#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [--noconfirm] [--skip-packages] [--skip-services] [--stow]

Set up yay and install the package lists in packages/.

Options:
  --noconfirm      Pass --noconfirm to pacman, makepkg, and yay.
  --skip-packages  Only prepare local dotfile state such as Niri local config.
  --skip-services  Do not enable or start systemd user services.
  --stow           Restow all dotfile packages into $HOME after installing packages.
  -h, --help       Show this help.
USAGE
}

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
noconfirm=()
skip_packages=false
skip_services=false
stow_dotfiles=false
cleanup_dirs=()

cleanup() {
  local dir
  for dir in "${cleanup_dirs[@]}"; do
    rm -rf -- "$dir"
  done
}
trap cleanup EXIT

while (($#)); do
  case "$1" in
  --noconfirm)
    noconfirm=(--noconfirm)
    ;;
  --skip-packages)
    skip_packages=true
    ;;
  --skip-services)
    skip_services=true
    ;;
  --stow)
    stow_dotfiles=true
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 2
    ;;
  esac
  shift
done

read_package_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  sed -E 's/[[:space:]]*#.*$//; /^[[:space:]]*$/d; s/^[[:space:]]+//; s/[[:space:]]+$//' "$file"
}

require_arch_user() {
  if [[ ! -e /etc/arch-release ]]; then
    echo "This setup script expects Arch Linux." >&2
    exit 1
  fi

  if [[ "${EUID}" -eq 0 ]]; then
    echo "Run this as your normal user. The script uses sudo only where needed." >&2
    exit 1
  fi
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    return 0
  fi

  sudo pacman -Syu --needed "${noconfirm[@]}" git base-devel

  local build_dir
  build_dir="$(mktemp -d)"
  cleanup_dirs+=("$build_dir")

  git clone https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
  (
    cd "$build_dir/yay-bin"
    makepkg -si --needed "${noconfirm[@]}"
  )
}

install_pacman_packages() {
  local packages=()
  mapfile -t packages < <(read_package_file "$repo_root/packages/pacman.txt")

  if ((${#packages[@]} == 0)); then
    return 0
  fi

  sudo pacman -Syu --needed "${noconfirm[@]}" "${packages[@]}"
}

install_aur_packages() {
  local packages=()
  mapfile -t packages < <(read_package_file "$repo_root/packages/aur.txt")

  if ((${#packages[@]} == 0)); then
    return 0
  fi

  yay -S --needed "${noconfirm[@]}" "${packages[@]}"
}

show_local_package_notes() {
  local packages=()
  mapfile -t packages < <(read_package_file "$repo_root/packages/local.txt")

  if ((${#packages[@]} == 0)); then
    return 0
  fi

  echo "These packages are local/private and were not installed automatically:"
  printf '  %s\n' "${packages[@]}"
}

install_repo_user_units() {
  local source_dir="$repo_root/systemd/.config/systemd/user"
  local systemd_source_dir="$repo_root/systemd/.config/systemd"
  local systemd_target_dir="$HOME/.config/systemd"
  local target_dir="$HOME/.config/systemd/user"
  local unit

  if [[ ! -d "$source_dir" ]]; then
    return 0
  fi

  unfold_repo_owned_symlink_dir "$systemd_target_dir" "$systemd_source_dir"
  mkdir -p -- "$systemd_target_dir"
  unfold_repo_owned_symlink_dir "$target_dir" "$source_dir"
  mkdir -p -- "$target_dir"
  while IFS= read -r -d '' unit; do
    ln -sfn -- "$unit" "$target_dir/$(basename "$unit")"
  done < <(find "$source_dir" -maxdepth 1 -type f -name '*.service' -print0)
}

unfold_repo_owned_symlink_dir() {
  local target_dir="$1"
  local source_dir="$2"
  local source_real
  local target_real

  if [[ ! -L "$target_dir" ]]; then
    return 0
  fi

  if ! target_real="$(readlink -f -- "$target_dir")"; then
    echo "Refusing to replace broken symlink: $target_dir" >&2
    exit 1
  fi

  source_real="$(readlink -f -- "$source_dir")"
  if [[ "$target_real" != "$source_real" ]]; then
    echo "Refusing to replace non-repo systemd symlink: $target_dir -> $(readlink -- "$target_dir")" >&2
    exit 1
  fi

  rm -- "$target_dir"
  echo "Converted Stow-folded systemd directory to a real directory: $target_dir"
}

ensure_shared_stow_container_dirs() {
  local rel
  local target_dir
  local target_real

  while IFS= read -r rel; do
    target_dir="$HOME/$rel"

    if [[ -L "$target_dir" ]]; then
      if ! target_real="$(readlink -f -- "$target_dir")"; then
        echo "Refusing to replace broken symlink: $target_dir" >&2
        exit 1
      fi

      case "$target_real" in
      "$repo_root"/*/"$rel")
        rm -- "$target_dir"
        echo "Converted Stow-folded shared directory to a real directory: $target_dir"
        ;;
      *)
        echo "Refusing to replace non-repo shared symlink: $target_dir -> $(readlink -- "$target_dir")" >&2
        exit 1
        ;;
      esac
    fi

    mkdir -p -- "$target_dir"
  done <<'EOF'
.config
.local
EOF
}

disable_user_services() {
  local services=()
  local service
  mapfile -t services < <(read_package_file "$repo_root/packages/user-services-disabled.txt")

  for service in "${services[@]}"; do
    systemctl --user disable --now "$service" >/dev/null 2>&1 || true
  done
}

ensure_user_services() {
  local services=()
  mapfile -t services < <(read_package_file "$repo_root/packages/user-services.txt")

  if ((${#services[@]} == 0)); then
    return 0
  fi

  if ! systemctl --user show-environment >/dev/null 2>&1; then
    echo "User systemd bus is unavailable; skipping user service start." >&2
    return 0
  fi

  install_repo_user_units
  systemctl --user daemon-reload
  disable_user_services

  if systemctl --user is-active --quiet graphical-session.target; then
    systemctl --user enable --now "${services[@]}"
  else
    systemctl --user enable "${services[@]}"
    echo "graphical-session.target is not active; user services will start in the next graphical session."
  fi
}

ensure_niri_local_config() {
  local local_config="$repo_root/niri/.config/niri/config.local.kdl"
  local example_config="$repo_root/niri/.config/niri/config.local.kdl.example"

  if [[ -e "$local_config" ]]; then
    return 0
  fi

  cp -- "$example_config" "$local_config"
  echo "Created ignored Niri local config: $local_config"
}

create_dotfiles_backup_dir() {
  local backup_dir
  local suffix=0
  local timestamp

  timestamp="$(date +%Y%m%dT%H%M%S)"
  backup_dir="$HOME/.dotfiles.bak/$timestamp"
  while [[ -e "$backup_dir" ]]; do
    suffix=$((suffix + 1))
    backup_dir="$HOME/.dotfiles.bak/${timestamp}-$suffix"
  done

  mkdir -p -- "$backup_dir"
  printf '%s\n' "$backup_dir"
}

is_shared_stow_container() {
  case "$1" in
  .config | .local)
    return 0
    ;;
  esac

  return 1
}

package_target_dirs() {
  local package="$1"
  local rel

  while IFS= read -r -d '' rel; do
    if is_shared_stow_container "$rel"; then
      continue
    fi

    printf '%s\0' "$rel"
  done < <(find "$repo_root/$package" -mindepth 1 -maxdepth 2 -type d -printf '%P\0' | sort -z)
}

backup_existing_stow_dirs() {
  local backup_dir=""
  local backup_target
  local package
  local rel
  local target

  for package in "$@"; do
    while IFS= read -r -d '' rel; do
      target="$HOME/$rel"

      if [[ ! -d "$target" || -L "$target" ]]; then
        continue
      fi

      if [[ -z "$backup_dir" ]]; then
        backup_dir="$(create_dotfiles_backup_dir)"
      fi

      backup_target="$backup_dir/$rel"
      mkdir -p -- "$(dirname -- "$backup_target")"
      mv -- "$target" "$backup_target"
      echo "Backed up existing directory before Stow: $target -> $backup_target"
    done < <(package_target_dirs "$package")
  done
}

restow_dotfiles() {
  local package_dirs=()
  local dir

  if ! command -v stow >/dev/null 2>&1; then
    echo "stow is not installed; rerun without --skip-packages or install stow first." >&2
    exit 1
  fi

  while IFS= read -r -d '' dir; do
    case "$dir" in
    .git | packages | systemd)
      continue
      ;;
    esac
    package_dirs+=("$dir")
  done < <(find "$repo_root" -mindepth 1 -maxdepth 1 -type d -printf '%f\0' | sort -z)

  if ((${#package_dirs[@]} == 0)); then
    return 0
  fi

  backup_existing_stow_dirs "${package_dirs[@]}"
  ensure_shared_stow_container_dirs

  (
    cd "$repo_root"
    stow --target="$HOME" --restow "${package_dirs[@]}"
  )
  fish -c "tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_spacing=Compact --icons='Few icons' --transient=Yes"
}

require_arch_user
ensure_niri_local_config

if [[ "$skip_packages" == false ]]; then
  ensure_yay
  install_pacman_packages
  install_aur_packages
  show_local_package_notes
fi

if [[ "$stow_dotfiles" == true ]]; then
  restow_dotfiles
fi

if [[ "$skip_services" == false ]]; then
  ensure_user_services
fi
