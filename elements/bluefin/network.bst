kind: manual

# No external sources - all files are inline.
build-depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  # No external sources — nothing for the license stripper to scan.
  install-extra: ""

config:
  install-commands:
  - |
    install -Dm644 /dev/stdin "%{install-root}%{indep-libdir}/tmpfiles.d/bluefin-network.conf" <<'EOF'
    # Symlink /etc/resolv.conf to systemd-resolved's stub resolver.
    # L+ removes any existing file (e.g. the empty placeholder from the base image)
    # so applications that read resolv.conf directly (Steam, Distrobox, etc.) get DNS.
    L+ /etc/resolv.conf - - - - /run/systemd/resolve/stub-resolv.conf
    # Overwrite /etc/hosts at boot so it is never an empty placeholder.
    # f+ truncates any existing file and writes the minimal localhost entries.
    f+ /etc/hosts 0644 - - - "127.0.0.1 localhost\n::1 localhost ip6-localhost ip6-loopback\n"
    EOF

  - "%{install-extra}"
