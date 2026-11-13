# Vimarsha Learning Workstation

A friendly, ready-to-use NixOS desktop for school, drawing, mathematics, writing, and programming. It uses KDE Plasma, VSCodium, Firefox and Chromium, LibreOffice, creative apps, Bun/JavaScript, Python, and Java. The setup detects the computer’s own hardware and keeps the existing NixOS state version.

## Parent: install or update

This configuration is intended for a computer that already has a standard NixOS installation, a normal login for Vimarsha, and `sudo`. It does not repartition a drive or install the operating system from scratch. Keep a backup of irreplaceable files before replacing a machine’s system configuration.

Once this repository has its Git remote, the simple update sequence is:

```sh
git pull
./setup.sh
sudo nixos-rebuild switch
```

Run `setup.sh` as Vimarsha’s normal login, without `sudo`. It detects the username, home folder, hostname, processor, EFI/BIOS mode, and existing NixOS state version. It creates a hardware configuration from the target computer, saves any old `/etc/nixos` as a timestamped backup, and links this checkout as `/etc/nixos`. It then runs a dry build and restores the previous link if that check fails. The setup script does not partition disks, choose a disk to erase, create accounts, or run the final system switch.

After the rebuild, sign out and back in once. Verify the configuration with:

```sh
vimarsha-check
```

If that prints `VIMARSHA LEARNING COMPUTER` and the correct hostname, this is the expected configuration. `vimarsha-welcome` prints Vimarsha’s short first-use tour. The identifier does not include private information or credentials.

In a terminal, `refresh` is an alias for `sudo nixos-rebuild switch`. Use it whenever you intentionally want to activate changes early.

### Automatic updates

NixOS automatically refreshes packages from the NixOS 26.05 stable channel daily. It updates the system channel without changing the working tree or interfering with `git pull`. The computer needs to be on and connected to the internet; missed timer runs resume when it next starts. Updates activate without a forced reboot. You can inspect them with:

```sh
systemctl status vimarsha-auto-upgrade.timer
journalctl -u vimarsha-auto-upgrade.service
```

The operating-system configuration comes from this Git checkout. `git pull` obtains its new changes; the daily NixOS auto-upgrade service refreshes stable system packages independently. Setup keeps machine identity and hardware data in ignored local files, outside Git.

### If setup needs to be undone

The previous `/etc/nixos` is kept as `/etc/nixos.vimarsha-backup-DATE`. To point the default rebuild command back at it, remove the `/etc/nixos` symlink and rename that backup to `/etc/nixos`, then run `sudo nixos-rebuild switch`. NixOS also keeps prior system generations available in the boot menu.

## Vimarsha: start exploring

Your desktop is ready before you begin. Open **VSCodium** from the applications menu to write code, **Firefox** to research, **Chromium** for MakeCode and micro:bit USB experiments, **LibreOffice** for documents, or **Krita** and **Inkscape** for drawing. Your project folder is `Documents/Projects/Vimarsha`. The VSCodium extension panel uses Open VSX, so you can add extensions from inside the editor when a project needs them.

Open Konsole and run `vimarsha-check` if you want to confirm the computer is ready. Run `vimarsha-welcome` for a quick guide. You can draw and reason on paper first, try an idea in code, and ask for help at any point. There is no setup task you need to finish before learning.

The installed command-line tools include:

- Bun and Node.js for the JavaScript journeys
- OpenJDK 21, Maven, and Gradle for Java
- Python with NumPy, Matplotlib, pandas, SymPy, JupyterLab, pipx, and uv
- Git and Git LFS for saving project versions
- Pandoc, TeX Live, GNUplot, and Graphviz for school documents, plots, and diagrams

The desktop includes a web browser, office suite, drawing tools, PDF reader, media player, and KDE file manager, terminal, and screenshot tool.

## Physical materials to have nearby

The computer does not replace a few simple materials: graph/blank paper, pencil and colored pencils, small cards or tiles, a notebook, charger, and headphones if useful. The optional sensor work uses a micro:bit V2 and a USB data cable. A movement trial worn on the body requires parent and coach approval and a secure soft holder; desk-held or invented readings work as alternatives. Do not store another learner’s private information in a project.

## GitHub repository

The private repository is <https://github.com/sahastasai/vimarsha-nixos>. Clone it on Vimarsha’s NixOS computer, then use the parent setup steps above. The ordinary `git pull` workflow continues to work because machine identity and hardware files are ignored by Git.
