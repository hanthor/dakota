#!/usr/bin/env bash
# Spike probe: what the Dakota image offers the image-based installer.
# Usage (root): probe.sh IMAGE OUTDIR
set -uo pipefail
IMAGE="$1" OUT="$2"
mkdir -p "$OUT"
run() { podman run --rm --entrypoint bash "$IMAGE" -c "$1"; }

run '
set +e
uname -r; ls /usr/lib/modules; cat /usr/lib/os-release
echo "== binaries"
for b in python3 sudo run0 pkexec cryptsetup btrfs btrfstune mkfs.btrfs efibootmgr bootctl tune2fs e2fsck mkfs.fat mkfs.xfs xfs_admin sfdisk systemd-repart lsblk blkid wipefs udevadm sshd plymouth-set-default-theme plymouth flatpak getenforce aa-status mount.composefs bootc skopeo fsverity gdbus systemd-run runuser zstd; do printf "%-28s %s\n" "$b" "$(command -v "$b" || echo MISSING)"; done
echo "== python"; python3 --version
python3 - <<PY
import importlib
for m in ("yaml", "gi"):
    try:
        importlib.import_module(m); print(m, "ok")
    except Exception as e:
        print(m, "MISSING", e)
try:
    import gi
    for ns, v in (("Gtk","4.0"),("Adw","1"),("GnomeDesktop","4.0"),("GWeather","4.0"),("Vte","3.91"),("UDisks","2.0"),("Atspi","2.0"),("NM","1.0")):
        try:
            gi.require_version(ns, v); importlib.import_module("gi.repository."+ns); print(ns, v, "ok")
        except Exception as e:
            print(ns, v, "MISSING", e)
except Exception as e:
    print("gi failed", e)
PY
ls /usr/lib/python3*/site-packages | head -80
echo "== bootc install config"; ls -la /usr/lib/bootc /usr/lib/bootc/install /usr/lib/bootc/kargs.d 2>&1; cat /usr/lib/bootc/install/*.toml /usr/lib/bootc/kargs.d/*.toml 2>&1
echo "== prepare-root"; cat /usr/lib/ostree/prepare-root.conf 2>&1; cat /usr/lib/composefs/*.conf 2>&1
echo "== flatpak preinstall"; ls -la /usr/share/flatpak/preinstall.d /etc/flatpak/preinstall.d 2>&1; cat /usr/share/flatpak/preinstall.d/* 2>&1 | head -200
ls -la /var/lib/flatpak 2>&1 | head
echo "== flatpak remotes"; ls /usr/share/flatpak/remotes.d /etc/flatpak/remotes.d 2>&1
echo "== security"; ls /etc/selinux 2>&1; ls /usr/share/selinux 2>&1 | head; ls /etc/apparmor.d 2>&1 | head; ls /usr/lib/apparmor 2>&1 | head
echo "== plymouth"; plymouth-set-default-theme 2>&1; cat /usr/share/plymouth/plymouthd.defaults 2>&1; ls /usr/share/plymouth/themes 2>&1
echo "== gdm"; ls /etc/gdm /usr/share/gdm 2>&1; cat /etc/gdm/custom.conf 2>&1
echo "== units"; ls /usr/lib/systemd/system | grep -iE "bootc|live|repart|composefs|flatpak|uupd|update|secure|growpart|firstboot|ssh|initial|gdm|boot" 
echo "== systemd"; systemctl --version | head -2
echo "== sshd config"; ls /usr/lib/systemd/system/sshd* /usr/lib/systemd/system/ssh* 2>&1; ls /etc/ssh /usr/etc/ssh /usr/share/ssh 2>&1
echo "== users"; getent passwd | head -50; getent group wheel sudo
echo "== sudoers"; ls -la /etc/sudoers.d 2>&1; cat /etc/sudoers 2>&1 | grep -v "^#" | grep -v "^$" | head
echo "== polkit"; ls /usr/share/polkit-1/rules.d 2>&1
echo "== efi"; find /usr/lib/systemd/boot /usr/share/factory/efi /usr/lib/dakota /usr/lib/bootupd /usr/lib/efi 2>/dev/null | head -40
echo "== modules dir"; ls -la /usr/lib/modules/*/ | head -40
echo "== etc fstab"; cat /etc/fstab 2>&1
echo "== gnome-initial-setup"; ls /usr/libexec/gnome-initial-setup* /usr/share/gnome-initial-setup 2>&1; cat /usr/share/gnome-initial-setup/vendor.conf 2>&1
echo "== autostart"; ls /etc/xdg/autostart 2>&1
echo "== desktop terminal"; ls /usr/share/applications | grep -iE "term|ptyxis|console" 
' >"$OUT/image-facts.txt" 2>&1
cat "$OUT/image-facts.txt"

# The initramfs, listed and its systemd units extracted.
kver_files="$(podman run --rm --entrypoint bash "$IMAGE" -c 'ls /usr/lib/modules/*/initramfs.img /usr/lib/modules/*/*.efi 2>/dev/null')"
echo "initramfs files: ${kver_files}"
ctr="$(podman create "$IMAGE" true)"
mkdir -p "$OUT/initrd"
for f in ${kver_files}; do podman cp "$ctr:$f" "$OUT/initrd/"; done
podman rm "$ctr" >/dev/null
ls -la "$OUT/initrd"
if [[ -f "$OUT/initrd/initramfs.img" ]]; then
    file "$OUT/initrd/initramfs.img"
    head -c 6 "$OUT/initrd/initramfs.img" | od -c | head -2
    lsinitramfs -l "$OUT/initrd/initramfs.img" >"$OUT/initrd-list.txt" 2>&1 || true
    wc -l "$OUT/initrd-list.txt"
    mkdir -p "$OUT/initrd/x"
    unmkinitramfs "$OUT/initrd/initramfs.img" "$OUT/initrd/x" 2>&1 | tail -5
    ls "$OUT/initrd/x"
    rm -f "$OUT/initrd/initramfs.img"
    grep -E "volatile|bootc|ostree|repart|live|composefs|cryptsetup|plymouth|sysroot" "$OUT/initrd-list.txt" | head -80
    for u in bootc-root-setup.service ostree-prepare-root.service systemd-volatile-root.service sysroot.mount initrd-root-fs.target; do
        find "$OUT/initrd/x" -name "$u" -print -exec cat {} \; 2>/dev/null
    done
    find "$OUT/initrd/x" -path '*system/*.d/*' -print -exec cat {} \; 2>/dev/null | head -100
    find "$OUT/initrd/x" -path '*generator*' -type f | head -30
    tar -C "$OUT/initrd/x" -czf "$OUT/initrd-etc-units.tgz" $(cd "$OUT/initrd/x" && find . -path '*systemd/system*' -o -path '*etc*' -type f | head -2000) 2>/dev/null
    rm -rf "$OUT/initrd/x"
fi
