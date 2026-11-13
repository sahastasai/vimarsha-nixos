# Standard NixOS configuration: sudo nixos-rebuild switch works directly.
let
  identityFile = if builtins.pathExists ./identity.local.nix
    then ./identity.local.nix
    else ./identity.nix;
  hardwareFile = if builtins.pathExists ./hosts/vimarsha/hardware-configuration.local.nix
    then ./hosts/vimarsha/hardware-configuration.local.nix
    else ./hosts/vimarsha/hardware-configuration.nix;
  identity = import identityFile;
in
{
  imports = [
    hardwareFile
    ./hosts/vimarsha/configuration.nix
    ./modules/learning-workstation.nix
  ];
  _module.args.identity = identity;
}
