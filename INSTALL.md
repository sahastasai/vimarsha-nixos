# Parent setup card

## One-time setup on Vimarsha’s computer

1. Install NixOS using the official graphical installer. Create Vimarsha’s regular user and enable sudo for a trusted administrator. This config assumes NixOS is installed; `setup.sh` will not format or repartition a drive.
2. Clone <https://github.com/sahastasai/vimarsha-nixos> into her home folder.
3. In a terminal opened in the checkout, run:

   ```sh
   git pull
   ./setup.sh
   sudo nixos-rebuild switch
   ```

4. Type `VIMARSHA` when the script displays the detected username, computer, architecture, and boot setup. It saves `/etc/nixos` as a dated backup before registering the checkout.
5. When the rebuild finishes, sign out and in once. Run `vimarsha-check` and confirm the hostname.

## Routine config updates

For changes you publish to the private repository:

```sh
git pull
./setup.sh
sudo nixos-rebuild switch
```

The script refreshes detected hardware and identity, runs a dry build, and keeps `/etc/nixos` pointed at this checkout. The stable NixOS channel updates automatically each day without changing the Git checkout.

## Private machine files

The setup-generated identity and hardware files are ignored by Git. Keep this repository private because those values reveal an account name, home path, computer name, and disk identifiers. No passwords or service login credentials are part of this configuration.
