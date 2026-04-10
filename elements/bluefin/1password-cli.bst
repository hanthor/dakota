kind: manual

sources:
- kind: zip
  base-dir: ""
  (?):
  - arch == "x86_64":
      url: onepassword_cli:v2.33.1/op_linux_amd64_v2.33.1.zip
      ref: 0fc50cb22d791b5ee5e1421d97e96595fd61ca56ae92271bd1b28bb884971726
  - arch == "aarch64":
      url: onepassword_cli:v2.33.1/op_linux_arm64_v2.33.1.zip
      ref: b4b32cf5860d8353b99429c1fc65d11f2b04a9a2a9f4d06b747b8c07929216f0

build-depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
  - |
    install -Dm755 -t "%{install-root}%{bindir}" op
  - |
    %{install-extra}
