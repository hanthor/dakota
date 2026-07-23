kind: manual

build-depends:
- filename: freedesktop-sdk.bst:components/linux.bst
  strict: true
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
  - |
    mkdir -p "%{install-root}/usr/lib"
    cp -rT /usr/lib/modules "%{install-root}/usr/lib/modules"

  - |
    version="$(ls -1 /usr/lib/modules | head -n1)"
    cp /boot/vmlinuz "%{install-root}/usr/lib/modules/${version}"

  - |
    # Keep the device trees the kernel installed via dtbs_install
    # (/boot is wiped at image assembly). Layout matches what the
    # Asahi/U-Boot boot chain and kernel-install expect:
    # /usr/lib/modules/<kver>/dtb/<vendor>/*.dtb
    if [ -d /boot/dtbs ]; then
      version="$(ls -1 /usr/lib/modules | head -n1)"
      mkdir -p "%{install-root}/usr/lib/modules/${version}/dtb"
      cp -rT /boot/dtbs "%{install-root}/usr/lib/modules/${version}/dtb"
    fi
