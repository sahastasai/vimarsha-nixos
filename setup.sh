#!/usr/bin/env bash
set -Eeuo pipefail

fail() { printf 'Setup stopped: %s\n' "$*" >&2; exit 1; }
info() { printf '\n%s\n' "$*"; }

[[ "$(id -u)" -ne 0 ]] || fail "Run as Vimarsha's normal login, without sudo. The script requests sudo only when needed."
[[ -e /etc/NIXOS ]] || fail "NixOS must be installed first. This script will not partition a drive or install the operating system."
for command in nix nixos-rebuild nix-channel git sudo getent findmnt lsblk; do
  command -v "$command" >/dev/null || fail "Required command is missing: $command"
done

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
target_user="$(id -un)"
passwd_entry="$(getent passwd "$target_user")"
target_home="$(printf '%s\n' "$passwd_entry" | cut -d: -f6)"
full_name="$(printf '%s\n' "$passwd_entry" | cut -d: -f5 | cut -d, -f1)"
host_name="$(hostname -s)"
[[ -n "$target_home" && -d "$target_home" ]] || fail "Could not identify the login home directory."
[[ -n "$full_name" ]] || full_name="$target_user"

case "$(uname -m)" in
  x86_64) target_system=x86_64-linux ;;
  aarch64|arm64) target_system=aarch64-linux ;;
  *) fail "Unsupported processor architecture: $(uname -m)" ;;
esac

if [[ -d /sys/firmware/efi ]]; then
  boot_mode=uefi
  efi_mount="$(findmnt -rn -M /boot -o TARGET 2>/dev/null || true)"
  [[ -n "$efi_mount" ]] || efi_mount="$(findmnt -rn -M /boot/efi -o TARGET 2>/dev/null || true)"
  [[ -n "$efi_mount" ]] || fail "UEFI is enabled, but the EFI partition is not mounted at /boot or /boot/efi. Check the NixOS installation first."
  grub_device=nodev
else
  boot_mode=bios
  efi_mount=/boot
  root_source="$(findmnt -nro SOURCE / | sed 's/\[.*$//')"
  grub_device="$(lsblk -sno PATH,TYPE "$root_source" 2>/dev/null | awk '$2 == "disk" {print $1; exit}')"
  [[ -n "$grub_device" ]] || fail "Could not identify the BIOS boot disk. Stop here and ask for help before choosing a disk."
fi

installed_version="$(nixos-version 2>/dev/null | sed -E 's/^([0-9]+\.[0-9]+).*/\1/' || true)"
[[ "$installed_version" =~ ^[0-9]+\.[0-9]+$ ]] || installed_version=26.05

cat <<SUMMARY

VIMARSHA LEARNING COMPUTER SETUP
Configuration: vimarsha-learning-workstation
Account:       $target_user
Computer:      $host_name ($target_system)
Boot:          $boot_mode${efi_mount:+ at $efi_mount}
NixOS state:   $installed_version
Checkout:      $repo_dir

This will save any existing /etc/nixos as a dated backup, prepare local
machine settings and link this checkout as /etc/nixos. It will build a
diagnostic dry run, but not activate it. The final step remains:

  sudo nixos-rebuild switch
SUMMARY
read -r -p "Type VIMARSHA to prepare this computer: " answer
[[ "$answer" == VIMARSHA ]] || fail "Nothing was changed. Run setup.sh again when ready."

escape_nix_string() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//\$\{/\\\$\{}"
  printf '%s' "$value"
}
identity_file="$repo_dir/identity.local.nix"
cat > "$identity_file" <<IDENTITY
{
  username = "$(escape_nix_string "$target_user")";
  fullName = "$(escape_nix_string "$full_name")";
  homeDirectory = "$(escape_nix_string "$target_home")";
  hostName = "$(escape_nix_string "$host_name")";
  system = "$target_system";
  bootMode = "$boot_mode";
  efiSysMountPoint = "$efi_mount";
  grubDevice = "$grub_device";
  timeZone = "America/Los_Angeles";
  systemStateVersion = "$installed_version";
}
IDENTITY
chmod 0644 "$identity_file"

mkdir -p "$target_home/Documents/Projects/Vimarsha"
hardware_tmp="$repo_dir/hosts/vimarsha/hardware-configuration.local.nix.tmp"
sudo nixos-generate-config --show-hardware-config > "$hardware_tmp"
chmod 0644 "$hardware_tmp"
mv "$hardware_tmp" "$repo_dir/hosts/vimarsha/hardware-configuration.local.nix"

info "Preparing stable NixOS package updates..."
sudo nix-channel --add https://nixos.org/channels/nixos-26.05 nixos
sudo nix-channel --update nixos

stamp="$(date +%Y%m%d-%H%M%S)"
backup=""
if sudo test -L /etc/nixos; then
  current_target="$(sudo readlink -f /etc/nixos || true)"
  if [[ "$current_target" != "$repo_dir" ]]; then
    backup="/etc/nixos.vimarsha-backup-$stamp"
    sudo mv /etc/nixos "$backup"
  fi
elif sudo test -e /etc/nixos; then
  backup="/etc/nixos.vimarsha-backup-$stamp"
  sudo mv /etc/nixos "$backup"
fi
if ! sudo test -e /etc/nixos; then sudo ln -s "$repo_dir" /etc/nixos; fi

info "Checking that the detected hardware and workstation config build..."
if ! sudo nixos-rebuild dry-build --show-trace; then
  sudo rm /etc/nixos
  if [[ -n "$backup" ]]; then sudo mv "$backup" /etc/nixos; fi
  fail "The dry build did not pass. The prior /etc/nixos has been restored. Send the error output for help."
fi

info "Setup is ready. Finish with: sudo nixos-rebuild switch"
printf 'After it finishes, sign out and in once, then run: vimarsha-check\n'
if [[ -n "$backup" ]]; then printf 'Previous configuration backup: %s\n' "$backup"; fi
