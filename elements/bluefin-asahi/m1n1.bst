kind: make
description: |
  m1n1 — the Asahi Linux stage-2 bootloader. Installed to
  /usr/lib/asahi-boot/m1n1.bin where update-m1n1 assembles
  boot.bin (m1n1 + Apple DTBs + U-Boot) onto the ESP.

  Build notes, all pinned:
  - CHAINLOADING=1 (the ESP flow chainloads stage1 -> stage2) pulls the
    Rust part: no-std staticlib for aarch64-unknown-none-softfloat via
    BUILDSTD=1 (-Zbuild-std, RUSTC_BOOTSTRAP exported by the Makefile)
    with fdsdk rust + rust-src.
  - Registry crates (bitflags/log/uuid) are vendored by the cargo2
    source (refs hand-pinned from rust/Cargo.lock); fatfs comes from
    the rust-fatfs submodule staged as a second git_repo source;
    `versions` is in-tree.
  - The boot-logo .rgba payloads normally come from ImageMagick over
    the artwork submodule's PNGs; neither exists in our junctions, so
    files/m1n1/*.rgba are pre-rendered (Pillow, byte-identical recipe:
    flatten onto black, raw RGBA8) and dropped into build/ so make
    skips the `magick` rule entirely.

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:components/rust-src.bst

variables:
  make-args: >-
    CHAINLOADING=1
    BUILDSTD=1
    RELEASE=1
  make-install-args: ''

config:
  configure-commands:
  - |
    # Point cargo at the crates the cargo2 source vendored.
    mkdir -p .cargo
    cat > .cargo/config.toml <<'EOF'
    [source.crates-io]
    replace-with = "vendored-sources"
    [source.vendored-sources]
    directory = ".vendored-crates"
    EOF

  - |
    # Pre-rendered boot logos: place where the build expects the
    # ImageMagick outputs so the data/%.png -> build/%.rgba rule
    # (which needs `magick`) is never invoked.
    mkdir -p build
    cp bootlogo_128.rgba build/bootlogo_128.rgba
    cp bootlogo_256.rgba build/bootlogo_256.rgba

  install-commands:
  - install -Dm644 build/m1n1.bin '%{install-root}%{prefix}/lib/asahi-boot/m1n1.bin'

sources:
- kind: git_repo
  url: github:AsahiLinux/m1n1.git
  track: v[0-9]*
  exclude:
  - '*-rc*'
  ref: v1.6.0-0-g2e6ac0b0b227fa4f89b27ba40f66aad6dd3a43a7
- kind: git_repo
  url: github:rafalh/rust-fatfs.git
  track: master
  ref-format: sha1
  ref: 4eccb50d011146fbed20e133d33b22f3c27292e7
  directory: rust/vendor/rust-fatfs
- kind: cargo2
  cargo-lock: rust/Cargo.lock
  vendor-dir: .vendored-crates
  ref:
  - kind: registry
    name: bitflags
    version: 2.9.2
    sha: 6a65b545ab31d687cff52899d4890855fec459eb6afe0da6417b8a18da87aa29
  - kind: registry
    name: log
    version: 0.4.27
    sha: 13dc2df351e3202783a1fe0d44375f7295ffb4049267b0f3018346dc122a1d94
  - kind: registry
    name: uuid
    version: 1.23.1
    sha: ddd74a9687298c6858e9b88ec8935ec45d22e8fd5e6394fa1bd4e99a87789c76
- kind: local
  path: files/m1n1/bootlogo_128.rgba
- kind: local
  path: files/m1n1/bootlogo_256.rgba
