# Abrar OS / Dyverz OS

Abrar OS (later renamed Dyverz OS) is Syed Abrar Ali's Arch Linux based desktop distribution. The idea is one ISO that can look and behave like several familiar desktops (Windows, macOS, Ubuntu, Fedora, Linux Mint, or plain GNOME / KDE) while staying a normal rolling Arch system underneath. On top of the desktop "looks" it adds a WinKernel layer (a shared, loop-mounted virtual `C:` partition used by Wine, Command Prompt and PowerShell, with DXVK/VKD3D for games), an `.exe`/`.msi` installer that publishes installed apps to the menu, a first-boot setup wizard, a driver manager, an update manager, a tabbed terminal with containerised Ubuntu/Kali profiles, and a live-ISO installer. The repository holds the build scripts that turn a stock Arch install or an `archiso` profile into that system.

## Where it is used

The repo is the source for a personal distribution that Abrar builds and tests in a VirtualBox VM reached over SSH; the VM is the build machine because `archiso` is not packaged for the Ubuntu laptop he works on. The older `build/` scripts produced the first GNOME-only "Abrar OS" image with a public no-password profile; the newer `dyverz-os/` tree is the multi-edition successor that is meant to be installed from a live ISO onto real hardware.

## How it works

### Two generations in one repo

| Tree | What it is |
|---|---|
| `build/` | Generation 1 ("Abrar OS"): numbered shell scripts run on the Arch live ISO and then inside the installed system. `01-base-install.sh` partitions `/dev/sda` (EFI + root), `pacstrap`s a base system with systemd-boot and a swap file. `02-stack.sh` installs GNOME, the app stack, an AUR helper, Flatpak/Snap, `apt`/`dpkg` shims that translate to pacman + `debtap`, a web-catalog "store" launcher, and a virtual NT kernel (persistent `wineserver` on a disk image mounted at `/mnt/cdrive`). `03-public.sh` turns it into a public kiosk-style OS (autologin, no lock screen, empty password). `04-setup-wizard.sh` + `setup/abrar-setup.py` install a GTK4/libadwaita first-boot wizard that runs full-screen under `cage` before GDM. `colab-build-iso.sh` builds an ISO for one flavour (gnome/plasma/cinnamon) inside an Arch chroot. |
| `dyverz-os/` | Generation 2 ("Dyverz OS"): a `Makefile` dev loop, an `airootfs/` overlay copied onto `/`, package lists per desktop, "looks" scripts, WinKernel, installer, and self-contained components (`terminal/`, `drivers/`, `updates/`, `setup/`, `winkernel/`) each with its own `install.sh`. |
| `PLAN.md` | Running plan and build log. |

### Dyverz OS build pipeline

1. `scripts/build-aur-repo.sh` builds every package in `packages/aur.txt` with `yay` and collects the results into a local pacman repository (`~/dyverz-repo`, `repo-add dyverz.db.tar.gz`), because `mkarchiso` can only pull from repositories.
2. `scripts/build-iso.sh <edition>` copies the `archiso` `releng` profile, writes `packages.x86_64` from `packages/base.txt` + the desktop lists chosen by `lib.sh::edition_lists` (windows/kde → KDE; mac/ubuntu/fedora/gnome → GNOME; mint → Cinnamon; all → everything), enables multilib and the local `[dyverz]` repo, rsyncs `airootfs/` in, creates the live user `dyverz` with GDM autologin into the edition's session, generates `profiledef.sh` (BIOS syslinux + UEFI GRUB, zstd squashfs), copies each component folder that has an `install.sh` into `/usr/share/dyverz/components/`, and writes a `customize_airootfs.sh` that runs branding, wallpaper generation, theme download and every component installer at image-build time. Finally it runs `mkarchiso`.
3. `scripts/install-stack.sh` does the equivalent for a running system (used for the VM dev loop): pacman + AUR packages, `apply-overlay.sh` (rsync `airootfs/` onto `/`, fix permissions, symlink `adduser`/`deluser`/`install-exe`), theme assets, wallpapers, services.

### Looks engine

`airootfs/usr/local/bin/dyverz-look` is a bash program that detects the running desktop (`XDG_CURRENT_DESKTOP` → gnome / kde / cinnamon) and maps generic keys to that desktop's mechanism: `gsettings` for GNOME and Cinnamon, `kwriteconfig6` / `plasma-apply-*` / a Plasma scripting call over D-Bus for KDE. Keys: `wallpaper icons theme cursor font taskbar.position taskbar.size taskbar.autohide startmenu keyboard.layout shortcut files settings editor boot.logo boot.title boot.background login.logo`. Values are persisted in `~/.config/dyverz/look.conf`. Each look (`usr/share/dyverz/looks/<name>.sh`) is a list of `default key value` lines plus a few desktop-specific tweaks; `common.sh` maps a look to its session (`look_session windows` → `plasma`). `dyverz-look apply <look>` loads those defaults and applies them; `apply-pending` runs at login via an autostart entry. `scripts/install-looks.sh` fetches third-party themes (WhiteSur for the mac look, Win11OS/Win11 icons for the windows look) from their public Git repositories; `make-wallpapers.sh` generates original gradient wallpapers with ImageMagick so no copyrighted artwork ships. `dyverz-boot` edits Plymouth, GRUB and the GDM logo. `dyverz-customize` is a GTK4 preferences window that simply calls `dyverz-look set/get`.

### WinKernel

`airootfs/usr/local/bin/winkernel` (and the older `winkernel/dyverz-winkernel`) manages a sparse disk image (default 32 GB, `WINKERNEL_SIZE`) under `/var/lib/winkernel/`. `winkernel boot` attaches it through a loop device, exposes it as `/dev/winkernel`, mounts it at `/mnt/cdrive` and creates the Windows folder skeleton; `winkernel.service` does this before the display manager. `winkernel init` creates a per-user Wine prefix (`~/.wine-cdrive`) whose `drive_c` is a symlink to the shared mount, so Wine, `wincmd` (Wine `cmd`), PowerShell and games all see the same `C:\`; `init --games` adds DXVK/VKD3D. `dyverz-exe-install <file|URL> [--game] [--silent]` downloads if needed, runs the installer with `winemenubuilder` enabled, diffs the Start Menu `.lnk` files before and after to report new shortcuts, and wraps game launchers in `gamemoderun`. `dyverz-game` launches an exe with esync/fsync and gamemode.

### First-boot setup

Two implementations exist. `setup/dyverz-setup` (GTK4, runs in a `cage` kiosk as a dedicated system user that GDM auto-logs in, armed by `dyverz-firstboot-enable` / `dyverz-firstboot.service`) collects edition, default apps, admin user, computer name and autologin, writes `/etc/dyverz/setup.json` (password stripped) and hands it to `setup/dyverz-apply`, a 12-step root script: hostname/timezone/locale, Ubuntu-style first-user-is-admin (wheel + polkit rule), package install for the chosen edition, display-manager selection and autologin, default apps via `mimeapps.list`, and so on; `DRY_RUN=1` prints instead of changing. `setup/dyverz-setup-tui` is a whiptail fallback for a tty or SSH. The lighter `airootfs` pair `dyverz-setup` / `dyverz-setup-apply` creates the user with `dyverz-adduser`, sets the session with `dyverz-session`, writes `look.conf` with `pending=1` and turns autologin off.

### Other components

- `airootfs/usr/local/bin/dyverz-install`: dialog-based live installer. GPT with BIOS-boot, EFI and root partitions, ext4 or btrfs, `rsync` of the live root excluding archiso bits, `genfstab`, Plymouth hook in `mkinitcpio`, GRUB for both UEFI and BIOS, removes the live user, arms the first-boot wizard.
- `drivers/dyverz-drivers`: scans `lspci`/`lsusb`/`/proc/cpuinfo`/`systemd-detect-virt`, builds a Device-Manager style table (microcode, GPU + Vulkan/VA-API, VM guest tools, network, Bluetooth, audio, battery, fingerprint, printing, fwupd) and installs what is missing; `win` sets up DXVK, fonts and runtimes in the WinKernel prefix. `dyverz-device-manager` is the GTK front-end.
- `updates/dyverz-update`: one view over pacman (`checkupdates`), AUR (`yay -Qua`), Flatpak and Snap; policy `ask` / `download` / `manual` in `/etc/dyverz/updates.conf`; timers check every 6 h; installs only through `pkexec`. `dyverz-update-gui` is the dialog.
- `terminal/`: GTK4 + VTE tabbed terminal with profiles (login shell, Ubuntu and Kali via `distrobox` + rootless `podman`, Python, Wine Command Prompt, PowerShell) from `~/.config/dyverz-terminal/settings.json`; `dyverz-subids` adds sub-UID ranges.
- `dyverz-branding` rewrites `/etc/os-release` and `/etc/lsb-release` and is re-run by a pacman hook after `filesystem` upgrades.
- `editions/*.sh`: per-edition package sets and per-user first-login tweaks used by `dyverz-apply`.

## Setup

Requirements: an Arch Linux machine or VM for building (`archiso`, `yay`, `rsync`, `openssl`, ImageMagick, `git`, `base-devel`), SSH access to it from the development machine, and roughly 20 GB free disk for the AUR repo, work directory and ISO output. The laptop side only needs `make`, `ssh` and `rsync`.

```bash
git clone https://github.com/USER/abrar-os ~/arch-custom-os
cd ~/arch-custom-os/dyverz-os
# point the Makefile at your build VM (defaults are placeholders)
make sync VM=user@HOST PORT=22
```

Configuration points:

- `Makefile`: `VM`, `PORT`, `ED` (edition).
- `build-iso.sh`: `REPO`, `WORK`, `OUT` environment variables.
- `winkernel`: `WINKERNEL_SIZE`, or `IMG=` in `/etc/dyverz/winkernel.conf`.
- `/etc/dyverz/updates.conf`: `mode=ask|download|manual`.

## Usage

Development loop against the VM:

```bash
make stack ED=windows   # install everything into the running VM
make overlay            # re-copy scripts/config only
make aur                # build AUR packages into ~/dyverz-repo on the VM (once)
make iso ED=all         # build ~/dyverz-out/dyverz-os-all-*.iso on the VM
make fetch              # copy ISOs back to ./out/
```

On an installed system:

```bash
dyverz-look apply mac                 # switch to the macOS look
dyverz-look set taskbar.position left
winkernel status                      # C: partition, Wine version, loaded layers
install-exe ~/Downloads/setup.exe     # install a Windows program onto C:
wincmd /c "dir C:\"
dyverz-drivers scan
dyverz-update check
sudo dyverz-boot title "My OS"
```

Generation-1 flow: boot the Arch ISO, run `build/01-base-install.sh` as root, reboot, run `02-stack.sh`, optionally `03-public.sh` and `04-setup-wizard.sh`.

## Project structure

```
arch-custom-os/
├── PLAN.md
├── build/                     # generation 1 (Abrar OS)
│   ├── 01-base-install.sh  02-stack.sh  03-public.sh  04-setup-wizard.sh
│   ├── colab-build-iso.sh
│   └── setup/abrar-setup.py, abrar-setup.service
└── dyverz-os/                 # generation 2 (Dyverz OS)
    ├── Makefile  README.md
    ├── packages/              # base.txt gnome.txt kde.txt cinnamon.txt aur.txt
    ├── scripts/               # build-iso.sh build-aur-repo.sh install-stack.sh apply-overlay.sh
    │                          # install-looks.sh make-wallpapers.sh lib.sh
    ├── airootfs/              # overlay copied onto / (usr/local/bin/*, looks, services, dconf, skel)
    ├── editions/              # common.sh windows.sh mac.sh ubuntu.sh fedora.sh mint.sh
    ├── setup/                 # dyverz-setup (GTK) dyverz-setup-tui dyverz-apply dyverz-firstboot.service
    ├── winkernel/             # dyverz-winkernel dyverz-run EXE installer desktop files
    ├── drivers/  updates/  terminal/   # components, each with install.sh
    ├── branding/              # os-release, desktop entry
    └── colab/dyverz_build.ipynb        # bundles theme assets only
```

## Limitations and notes

- The ISO must be built on Arch (or in an Arch container with loop-device and `mkarchiso` support); the notebook under `dyverz-os/colab/` only packages theme assets because that environment cannot mount filesystems.
- The generation-1 scripts hard-code the target disk, hostname, username and password and copy the builder's SSH keys into the image; `03-public.sh` deliberately removes all passwords and screen locking. Review and strip these before publishing an image.
- The live ISO user and password are both `dyverz`; `dyverz-install` erases the whole chosen disk.
- The WinKernel is Wine on a shared loop-mounted image, not a Windows kernel; compatibility is whatever Wine, DXVK and VKD3D provide. The image is NTFS when `mkfs.ntfs` is available in the older script and ext4 in the newer one.
- Theme assets for the Windows and macOS looks are downloaded from third-party repositories at build time and are subject to their own licences.
- Several scripts assume systemd, GDM/SDDM/LightDM, NetworkManager and a UEFI or BIOS x86_64 machine; there is no ARM build.
