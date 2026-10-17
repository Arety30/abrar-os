# Dyverz OS

Arch-based, one ISO, any look: **Windows** (KDE Plasma + Win11OS), **macOS** (GNOME + WhiteSur), **Ubuntu** (GNOME + Yaru),
**Fedora** (stock GNOME), **Linux Mint** (Cinnamon + Mint-Y), plus plain GNOME / KDE.

## What's inside
| Piece | Where |
|---|---|
| App stack (Firefox, WPS Office 365, Thunderbird, VLC, Text Editor, TuxPaint, Emote on **F1**, Docker, Resources, Discover, GNOME Settings, PowerShell 7 preview, Wine 11) | `packages/*.txt` |
| Package managers: pacman, Flatpak (Flathub), Snap, apt + dpkg, **Dyverz Store** (Discover) | `packages/base.txt`, `dyverz-store.desktop` |
| **WinKernel** – virtual Windows kernel: loop-mounted 32 GB C: partition (`/mnt/cdrive`, `/dev/winkernel`) shared by Wine, `wincmd` (Command Prompt) and PowerShell (`C:\`); DXVK/VKD3D for games | `winkernel`, `winkernel.service`, `wincmd`, `dyverz-game` |
| **EXE installer** – double-click any .exe/.msi (or `install-exe file.exe`, `Install-WindowsApp` in pwsh) → installs onto C:, adds menu entries | `dyverz-exe-install` |
| **Looks** + full customisation engine (wallpaper, icons, theme, cursor, font, taskbar position/size/autohide, start-menu style, keyboard layout, shortcuts, pinned apps, boot logo/title/background, login logo) | `dyverz-look`, `usr/share/dyverz/looks/*.sh`, `dyverz-boot` |
| **Dyverz Customize** GUI for all of the above | `dyverz-customize` |
| **Ubuntu-style users**: `adduser` / `deluser`, `sudo` group | `dyverz-adduser` |
| **First-boot Setup wizard** (name, username, password, computer name, look, file manager / settings app / text editor) | `dyverz-setup`, `dyverz-setup-apply`, `dyverz-firstboot.service` |
| **Installer** on the live ISO (GPT, UEFI+BIOS GRUB, Plymouth) | `dyverz-install` |

## Dev loop (laptop → Arch VM on VirtualBox, ssh port 2222)
```
make stack            # install everything into the VM and try it: dyverz-look windows, winkernel status, dyverz-customize
make overlay          # re-copy only scripts/config after editing
make aur              # build AUR packages into ~/dyverz-repo (needed once for the ISO)
make iso ED=all       # or ED=windows|mac|ubuntu|fedora|mint  → ~/dyverz-out/dyverz-os-<ED>-*.iso on the VM
make fetch            # ISOs → ./out/
```
Live ISO: user `dyverz` / password `dyverz`, autologin into the edition's desktop, "Install Dyverz OS" on the desktop.

## Colab
`colab/dyverz_build.ipynb` — Colab cannot mount filesystems or run archiso, so it only bundles theme assets; the ISO is built on the VM.

## Dyverz Terminal (`terminal/`)
Windows-Terminal-style tabbed terminal (GTK4 + libadwaita + VTE). Profiles come from
`~/.config/dyverz-terminal/settings.json` (system default `/etc/dyverz/terminal.json`):

| Tab | Runs |
|---|---|
| Arch Linux | your login shell |
| Ubuntu | `distrobox enter dyverz-ubuntu` (ubuntu:24.04, created on first use, real `apt`) |
| Kali Linux | `distrobox enter dyverz-kali` (kalilinux/kali-rolling, created on first use) |
| Python | ipython, or `python3` |
| Command Prompt (Wine) | `wine cmd` in `~/.wine-dyverz` (C: drive) |
| PowerShell 7 Preview | `pwsh-preview` / `pwsh` |

Shortcuts: Ctrl+Shift+T new tab · Ctrl+Shift+W close · Ctrl+Tab switch · Ctrl+Shift+1…6 open profile N ·
Ctrl+Shift+C/V copy-paste · Ctrl+, settings · Ctrl+Alt+T opens it from the desktop (GNOME/Cinnamon/KDE).
Install: `sudo terminal/install.sh` (pulls vte4, distrobox, podman, Cascadia font; sets it as default terminal
and adds sub-UID ranges so rootless podman works). `dyverz-shell <profile>` runs any profile outside the app.
Note: the Kali image is ~1.3 GB unpacked; a 2 GB VM can thrash while pulling it, so pull it once with
`dyverz-shell kali` before demoing.

## Driver Manager (`drivers/`)
`dyverz-drivers scan` reads lspci/lsusb/cpuinfo/systemd-detect-virt and prints a Device-Manager table:
CPU microcode, GPU (NVIDIA open / AMD / Intel / virtual → Vulkan + VA-API + lib32), VM guest tools
(VirtualBox / VMware / QEMU / Hyper-V), network (+ broadcom-wl-dkms when needed), Bluetooth, audio
(PipeWire, sof-firmware), battery, fingerprint, Thunderbolt, camera, printing, fwupd on bare metal.
`dyverz-drivers install --yes` installs it (runs once at first boot via dyverz-drivers.service).
`dyverz-drivers win` sets up the Win Kernel side: DXVK/VKD3D when the GPU has Vulkan, corefonts, vcrun2022.
GUI: **Device Manager** (`dyverz-device-manager`).

## Update Manager (`updates/`)
`dyverz-update check` lists pacman (checkupdates), AUR (yay), Flatpak and Snap updates without touching anything.
Policy (`dyverz-update mode`): **ask** = check every 6 h and show the Dyverz Update dialog; **download** = also
pre-download pacman packages in the background, still install only on approval; **manual** = never prompt.
Install always goes through `pkexec dyverz-update install` (admin password). GUI: **Dyverz Update**.
