kind: make
description: |
  AsahiLinux housekeeping scripts: update-m1n1 (reassembles boot.bin on
  the ESP from /usr/lib/asahi-boot + the kernel's Apple DTBs),
  asahi-fwupdate, asahi-diagnose, first-boot. Only the plain `install`
  target — the dracut/mkinitcpio initramfs hooks do not apply to the
  GNOME OS initramfs generator (see the 50-asahi module instead).

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

variables:
  make-args: >-
    PREFIX=%{prefix}
    SYS_PREFIX=%{prefix}
  make-install-args: >-
    %{make-args}
    DESTDIR=%{install-root}
    install

config:
  install-commands:
    (>):
    - |
      # update-m1n1 refuses to run without DTBS configured; point it at
      # the device trees unsigned-modules stages into the modules tree.
      install -d "%{install-root}/etc/default"
      cat > "%{install-root}/etc/default/update-m1n1" <<'EOF'
      DTBS="/usr/lib/modules/*/dtb/apple/*.dtb"
      EOF

sources:
- kind: git_repo
  url: github:AsahiLinux/asahi-scripts.git
  track: '[0-9]*'
  ref: 20250713-0-g800400dcf9612edd10f00d306a39a499313cefe3
