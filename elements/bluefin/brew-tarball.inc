build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

runtime-depends:
  - bluefin/brew.bst

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      mkdir -p "%{install-root}%{datadir}"
      mv homebrew-%{arch}.tar.zst "%{install-root}%{datadir}/homebrew.tar.zst"
    - |
      %{install-extra}
