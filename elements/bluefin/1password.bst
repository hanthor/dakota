kind: manual

sources:
- kind: tar
  (?):
  - arch == "x86_64":
      url: onepassword_files:linux/tar/stable/x86_64/1password-8.12.8.x64.tar.gz
      ref: 58c0296af6064784d7d7f831f328f3688d121dfd42102f80cbd9c0cb108e2ecd
  - arch == "aarch64":
      url: onepassword_files:linux/tar/stable/aarch64/1password-8.12.8.arm64.tar.gz
      ref: 52ab78e28b5ce34fefeff7fdd2bd814b4c8ad53b9cb4e3b45547161a18efd292

build-depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/sed.bst

variables:
  strip-binaries: ""

config:
  install-commands:
  - |
    mkdir -p "%{install-root}/opt/1Password"
    cp -a . "%{install-root}/opt/1Password/"
  - |
    install -dm755 "%{install-root}%{bindir}"
    ln -sf /opt/1Password/1password "%{install-root}%{bindir}/1password"
  - |
    sed 's|/opt/1Password/1password|1password|g' \
        resources/1password.desktop > 1password.desktop.patched
    install -Dm644 1password.desktop.patched \
        "%{install-root}%{datadir}/applications/1password.desktop"
  - |
    for size in 32x32 64x64 256x256 512x512; do
      install -Dm644 "resources/icons/hicolor/${size}/apps/1password.png" \
          "%{install-root}%{datadir}/icons/hicolor/${size}/apps/1password.png"
    done
  - |
    chmod 4755 "%{install-root}/opt/1Password/chrome-sandbox"
  - |
    sed 's/${POLICY_OWNERS}//g' com.1password.1Password.policy.tpl \
        > com.1password.1Password.policy
    install -Dm644 -t "%{install-root}%{datadir}/polkit-1/actions" \
        com.1password.1Password.policy
  - |
    %{install-extra}
