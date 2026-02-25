build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 zig "%{install-root}%{bindir}/zig"
      mkdir -p "%{install-root}%{libdir}/zig"
      cp -a lib/* "%{install-root}%{libdir}/zig/"
