kind: make
description: |
  U-Boot from the AsahiLinux fork (apple_m1_defconfig). Provides the
  EFI environment m1n1 chainloads into; installed as
  /usr/lib/asahi-boot/u-boot-nodtb.bin where update-m1n1 expects it.

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/bc.bst
- freedesktop-sdk.bst:components/gzip.bst
- freedesktop-sdk.bst:components/openssl.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/swig.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/util-linux.bst

environment:
  KBUILD_BUILD_TIMESTAMP: 'Thu Nov 10 15:00:00 UTC 2011'
  KBUILD_BUILD_USER: 'tomjon'

config:
  configure-commands:
  - make apple_m1_defconfig

  install-commands:
  - install -Dm644 u-boot-nodtb.bin '%{install-root}%{prefix}/lib/asahi-boot/u-boot-nodtb.bin'

sources:
- kind: git_repo
  url: github:AsahiLinux/u-boot.git
  track: asahi-v[0-9]*
  exclude:
  - '*-rc*'
  ref: asahi-v2026.04-2-0-g3b233f59d0b6b57eae5add46a6fa7787ea11388e
