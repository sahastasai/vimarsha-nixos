{ config, lib, pkgs, identity, ... }:
{
  imports = [ ];

  networking.hostName = identity.hostName;
  networking.networkmanager.enable = true;
  time.timeZone = identity.timeZone;
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  boot.loader.systemd-boot.enable = identity.bootMode == "uefi";
  boot.loader.efi.canTouchEfiVariables = identity.bootMode == "uefi";
  boot.loader.grub.enable = identity.bootMode == "bios";
  boot.loader.grub.device = if identity.bootMode == "bios" then identity.grubDevice else "nodev";
  boot.loader.efi.efiSysMountPoint = identity.efiSysMountPoint;

  users.users.${identity.username} = {
    isNormalUser = true;
    description = identity.fullName;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "dialout" ];
  };
  security.sudo.wheelNeedsPassword = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.fwupd.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.graphics.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  services.flatpak.enable = true;
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };
  programs.git.enable = true;
  programs.nix-ld.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Update stable NixOS packages automatically; never force a reboot.
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-26.05";
    dates = "04:15";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };

  system.stateVersion = identity.systemStateVersion;
  systemd.tmpfiles.rules = [
    "d ${identity.homeDirectory}/Documents 0750 ${identity.username} users - -"
    "d ${identity.homeDirectory}/Documents/Projects 0750 ${identity.username} users - -"
    "d ${identity.homeDirectory}/Documents/Projects/Vimarsha 0750 ${identity.username} users - -"
  ];
}
