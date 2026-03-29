kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: zip
    url: onepassword_cli:v2.33.1/op_linux_arm64_v2.33.1.zip
    ref: b4b32cf5860d8353b99429c1fc65d11f2b04a9a2a9f4d06b747b8c07929216f0
    base-dir: ""

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" op
    - |
      %{install-extra}
