build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" fzf
    - |
      %{install-extra}
