# Custom Arch-based OS — plan (draft 2026-09-24)

ISO: beginging-iso/arch_x86_x64.iso  (ARCH_202609, 1.6 GB, bootable)

## VirtualBox settings
- Arch Linux 64-bit, 2 CPUs, 2048 MB RAM, 40 GB dynamic disk
- System > Enable EFI (build for UEFI)
- Nested paging + VT-x on
- ISO first in boot order

## Live-session checks
    ls /sys/firmware/efi/efivars     # exists = UEFI boot
    ping -c 3 archlinux.org          # pacstrap needs network

## Phases
1. Manual install in the VM (reference build) — follow the Arch wiki Installation Guide.
2. Turn that install into one rerunnable script (partition, pacstrap list, locale, users, bootloader).
3. In the VM: `pacman -S archiso`, copy /usr/share/archiso/configs/releng, edit packages.x86_64,
   airootfs/ overlay (configs + branding), boot menu; build with `mkarchiso -v -w work -o out .`
4. Put an installer on the ISO: the step-2 script or an archinstall preset.
5. Identity: desktop/WM, wallpaper, name, optional own package repo.
6. Real-hardware test from USB.

## Notes
- Laptop has 6.9 GB RAM; stop Ollama / heavy services before giving the VM 2 GB.
- archiso is not packaged for Ubuntu — the VM is the build machine.

## Build log (2026-09-25)
- VM "Arch": 60 GB disk Arch-sys.vdi, 2 GB RAM, EFI, NAT with host port 2222 -> guest 22 (ssh root@127.0.0.1 -p 2222, key auth).
- build/01-base-install.sh : base Arch on /dev/sda (systemd-boot, user abrar / pw abrar, wheel NOPASSWD, multilib on).
- build/02-stack.sh       : GNOME + full app stack, AUR via yay, flatpak/snap, apt+dpkg shims (debtap), virtual NT kernel
                            (ntoskrnl.service = wineserver on /var/lib/winkernel/cdrive.img mounted at /mnt/cdrive), wincmd/winrun/install-exe,
                            Microsoft Store launcher, Emote on F1, GDM autologin.
- Stale Arch.vdi (unattached, registered) can be dropped: VBoxManage closemedium disk Arch.vdi --delete once VM is off.
- PUBLIC OS: no login/lock/password (03-public.sh). Before shipping an ISO: delete /root/.ssh + ~/.ssh authorized_keys (they hold Abrar's laptop key).
- build/04-setup-wizard.sh + build/setup/ : Windows-style first-boot setup (GTK4/libadwaita, runs under cage before GDM; pages: welcome,
  region/language, keyboard, Wi-Fi, name/PC name/optional password, theme+wallpaper+desktop, apps, finish). Re-run: "Abrar OS Setup" app.

## Next stage (requested 2026-09-25): multi-desktop ISO on Google Colab GPU
- Build three flavours: GNOME (current), KDE Plasma, Cinnamon. Wizard's "Desktop" page already lists whatever sessions are installed.
- Do it with archiso inside a Docker/Arch container on Colab (GPU only helps if we prebuild AUR packages; ISO build itself is CPU/disk).
- Steps: archiso releng profile -> packages.x86_64 (+ plasma-meta / cinnamon) -> airootfs overlay = build/ scripts + setup wizard
  -> mkarchiso -> upload ISO to Drive. Strip Abrar's SSH keys from airootfs before building.
- 2026-09-25 10:00 VM state: GNOME autologin works (no login screen), stack pass 3 done (snapd, Tux Paint flatpak, apt/dpkg shims, MS Store launcher, Emote F1, wincmd, pwsh). Wine kernel section skipped: the Dyverz session's dyverz-winkernel owns /mnt/cdrive. Setup wizard verified live in the VM under cage (needs WLR_RENDERER=pixman in VirtualBox, no GLES2).
- 2026-09-25 10:05: TurboWarp added (flatpak org.turbowarp.TurboWarp, in 02-stack.sh + wizard app list + dock). Wizard redesigned: left step rail with progress, white card with eyebrow "STEP n OF 8", pill buttons, chips on welcome, ✓ finish. ABRAR_SETUP_PAGE=n env jumps to a page for previews; apply() now only touches the system as root on Abrar OS (ABRAR_SETUP_DRYRUN=1 forces preview).
