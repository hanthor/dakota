kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: zip
    url: onepassword_cli:v2.33.0/op_linux_arm64_v2.33.0.zip
    ref: 1d3862246186953b6d0585d17a9b5bbf5c89f2b000d21b32a4a9442ef1493c99
    base-dir: ""

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" op
    - |
      %{install-extra}
