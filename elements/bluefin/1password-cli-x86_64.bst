kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: zip
    url: onepassword_cli:v2.33.0/op_linux_amd64_v2.33.0.zip
    ref: 299f113a8591dc088b659ff1bf47252d7261856518d37999ac2440724025dce8
    base-dir: ""

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" op
    - |
      %{install-extra}
