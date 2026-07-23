kind: make
description: |
  Linux kernel from the Asahi Linux tree for Apple Silicon (M1/M2).

  Clone of freedesktop-sdk components/linux.bst with three changes:
  sources come from AsahiLinux/linux (asahi-* release tags), the
  upstream arch/arm64/configs/asahi.config fragment is merged on top
  of defconfig (16K pages, ARCH_APPLE, DRM_ASAHI + the rest of the
  Apple SoC support), and the fdsdk patch queue is dropped (it targets
  the stable tree the Asahi tree already rebases onto). The vendored
  fdsdk-config.sh/config-utils.sh under files/linux-asahi/ keep the
  fdsdk feature baseline (bpf, systemd, containers, ...) applied.

  Swapped in for every image on this branch via the
  components/linux.bst override in elements/freedesktop-sdk.bst.

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/cpio.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/bc.bst
- freedesktop-sdk.bst:components/gzip.bst
- freedesktop-sdk.bst:components/pahole.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/rsync.bst
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:components/rust-bindgen.bst
- freedesktop-sdk.bst:components/rust-src.bst
- freedesktop-sdk.bst:components/util-linux.bst
- freedesktop-sdk.bst:components/zstd.bst
- filename: freedesktop-sdk.bst:components/linux-module-cert.bst
  strict: true

variables:
  bootdir: /boot
  kernel_arch: '%{arch}'
  src-arch: '%{kernel_arch}'
  image-name: '$(make -s image_name)'
  optimize-debug: false
  (?):
  - arch == "aarch64":
      kernel_arch: arm64

environment:
  ARCH: '%{kernel_arch}'
  # compile.h has hardcoded timestamp, let's seed it
  KBUILD_BUILD_TIMESTAMP: 'Thu Nov 10 15:00:00 UTC 2011'
  KBUILD_BUILD_USER: 'tomjon'
  MAXJOBS: "%{max-jobs}"

environment-nocache:
- MAXJOBS

config:
  configure-commands:
  - |
    # defconfig + the Asahi tree's own merge fragment (16K pages,
    # ARCH_APPLE, DRM_ASAHI, Apple SoC drivers)
    make defconfig asahi.config

  - |
    . ./config-utils.sh
    rm -f expected-configs
    . ./fdsdk-config.sh "%{arch}"

  - |
    make -j1 olddefconfig

  - |
    . ./config-utils.sh

    missing_configs=0
    for config in $(cat expected-configs); do
      if ! has "${config}"; then
        echo "Missing ${config}" 1>&2
        missing_configs=1
      fi
    done
    [ "${missing_configs}" = 0 ]

  - |
    # The whole point of this element — fail loudly if the Asahi
    # fragment got clobbered by the fdsdk baseline or olddefconfig.
    for opt in CONFIG_ARCH_APPLE=y CONFIG_ARM64_16K_PAGES=y CONFIG_RUST=y; do
      grep -qx "${opt}" .config || { echo "FATAL: ${opt} missing from .config" >&2; exit 1; }
    done

  install-commands:
  - |
    install -Dm644 "%{image-name}" '%{install-root}%{bootdir}/vmlinuz'
    install -Dm644 vmlinux '%{install-root}%{bootdir}/vmlinux'
    install -Dm644 System.map '%{install-root}%{bootdir}/System.map'
    install -Dm644 .config '%{install-root}%{bootdir}/config'
    make -j1 INSTALL_MOD_PATH='%{install-root}%{prefix}' modules_install

  - |
    release=$(make -s kernelrelease)
    targetdir="%{install-root}%{prefix}/src/linux-${release}"

    rm "%{install-root}%{indep-libdir}/modules/${release}"/build

    to_copy=(
      Makefile
      Module.symvers
      .config
      "arch/%{src-arch}/include"
      "arch/%{src-arch}/Makefile"
      scripts
      include
    )
    if [ "$(scripts/config -s OBJTOOL)" = y ]; then
      to_copy+=(tools/objtool/objtool)
    fi
    for file in "${to_copy[@]}"
    do
      targetfile="${targetdir}/${file}"
      dir="$(dirname "${targetfile}")"
      [ -d "${dir}" ] || install -d "${dir}"
      cp -aT "${file}" "${targetfile}"
    done

    ln -sr "${targetdir}" "%{install-root}%{indep-libdir}/modules/${release}/build"

  - |
    make -j1 INSTALL_DTBS_PATH='%{install-root}%{bootdir}/dtbs' dtbs_install

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{bootdir}/System.map'
    overlap-whitelist:
    - "%{project_licensedir}"
    - "%{project_licensedir}/**"

sources:
- kind: git_repo
  url: github:AsahiLinux/linux.git
  track: asahi-[0-9]*
  exclude:
  - '*-rc*'
  ref: asahi-7.0.13-1-0-g030248d39b401c94695c9f7df2fed630d35120cd
- kind: local
  path: files/linux-asahi/config-utils.sh
- kind: local
  path: files/linux-asahi/fdsdk-config.sh
