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
  # -Zbuild-std resolves the SYSROOT's own lockfile against the vendored
  # registry too — these are rustc 1.95.0's library/Cargo.lock registry
  # crates (resolved, not all built). Regenerate when fdsdk bumps rust.
  - kind: registry
    name: addr2line
    version: "0.25.1"
    sha: 1b5d307320b3181d6d7954e663bd7c774a838b8220fe0593c86d9fb09f498b4b
  - kind: registry
    name: adler2
    version: "2.0.1"
    sha: 320119579fcad9c21884f5c4861d16174d0e06250625266f50fe6898340abefa
  - kind: registry
    name: cc
    version: "1.2.0"
    sha: 1aeb932158bd710538c73702db6945cb68a8fb08c519e6e12706b94263b36db8
  - kind: registry
    name: cfg-if
    version: "1.0.4"
    sha: 9330f8b2ff13f34540b44e946ef35111825727b38d33286ef986142615121801
  - kind: registry
    name: dlmalloc
    version: "0.2.11"
    sha: 06cdfe340b16dd990c54cce79743613fa09fbb16774f33a77c9fd196f8f3fa30
  - kind: registry
    name: foldhash
    version: "0.2.0"
    sha: 77ce24cb58228fbb8aa041425bb1050850ac19177686ea6e0f41a70416f56fdb
  - kind: registry
    name: fortanix-sgx-abi
    version: "0.6.1"
    sha: 5efc85edd5b83e8394f4371dd0da6859dff63dd387dab8568fece6af4cde6f84
  - kind: registry
    name: getopts
    version: "0.2.24"
    sha: cfe4fbac503b8d1f88e6676011885f34b7174f46e59956bba534ba83abded4df
  - kind: registry
    name: gimli
    version: "0.32.3"
    sha: e629b9b98ef3dd8afe6ca2bd0f89306cec16d43d907889945bc5d6687f2f13c7
  - kind: registry
    name: hashbrown
    version: "0.16.1"
    sha: 841d1cc9bed7f9236f321df977030373f4a4163ae1a7dbfe1a51a2c1a51d9100
  - kind: registry
    name: hermit-abi
    version: "0.5.2"
    sha: fc0fef456e4baa96da950455cd02c081ca953b141298e41db3fc7e36b1da849c
  - kind: registry
    name: libc
    version: "0.2.178"
    sha: 37c93d8daa9d8a012fd8ab92f088405fb202ea0b6ab73ee2482ae66af4f42091
  - kind: registry
    name: memchr
    version: "2.7.6"
    sha: f52b00d39961fc5b2736ea853c9cc86238e165017a493d1d5c8eac6bdc4cc273
  - kind: registry
    name: miniz_oxide
    version: "0.8.9"
    sha: 1fa76a2c86f704bdb222d66965fb3d63269ce38518b83cb0575fca855ebb6316
  - kind: registry
    name: moto-rt
    version: "0.16.0"
    sha: 29aea9f7dfeb258e030a84e0ec38a9c2ec2063d4f45eb2db31445cfc40b3dba1
  - kind: registry
    name: object
    version: "0.37.3"
    sha: ff76201f031d8863c38aa7f905eca4f53abbfa15f609db4277d44cd8938f33fe
  - kind: registry
    name: r-efi
    version: "5.3.0"
    sha: 69cdb34c158ceb288df11e18b4bd39de994f6657d83847bdffdbd7f346754b0f
  - kind: registry
    name: r-efi-alloc
    version: "2.1.0"
    sha: dc2f58ef3ca9bb0f9c44d9aa8537601bcd3df94cc9314a40178cadf7d4466354
  - kind: registry
    name: rand
    version: "0.9.2"
    sha: 6db2770f06117d490610c7488547d543617b21bfa07796d7a12f6f1bd53850d1
  - kind: registry
    name: rand_core
    version: "0.9.3"
    sha: 99d9a13982dcf210057a8a78572b2217b667c3beacbf3a0d8b454f6f82837d38
  - kind: registry
    name: rand_xorshift
    version: "0.4.0"
    sha: 513962919efc330f829edb2535844d1b912b0fbe2ca165d613e4e8788bb05a5a
  - kind: registry
    name: rustc-demangle
    version: "0.1.27"
    sha: b50b8869d9fc858ce7266cce0194bd74df58b9d0e3f6df3a9fc8eb470d95c09d
  - kind: registry
    name: rustc-literal-escaper
    version: "0.0.7"
    sha: 8be87abb9e40db7466e0681dc8ecd9dcfd40360cb10b4c8fe24a7c4c3669b198
  - kind: registry
    name: shlex
    version: "1.3.0"
    sha: 0fda2ff0d084019ba4d7c6f371c95d8fd75ce3524c3cb8fb653a3023f6323e64
  - kind: registry
    name: unwinding
    version: "0.2.8"
    sha: 60612c845ef41699f39dc8c5391f252942c0a88b7d15da672eff0d14101bbd6d
  - kind: registry
    name: vex-sdk
    version: "0.27.1"
    sha: 79e5fe15afde1305478b35e2cb717fff59f485428534cf49cfdbfa4723379bf6
  - kind: registry
    name: wasi
    version: "0.11.1+wasi-snapshot-preview1"
    sha: ccf3ec651a847eb01de73ccad15eb7d99f80485de043efb2f370cd654f4ea44b
  - kind: registry
    name: wasi
    version: "0.14.4+wasi-0.2.4"
    sha: 88a5f4a424faf49c3c2c344f166f0662341d470ea185e939657aaff130f0ec4a
  - kind: registry
    name: windows-link
    version: "0.2.1"
    sha: f0805222e57f7521d6a62e36fa9163bc891acd422f971defe97d64e70d0a4fe5
  - kind: registry
    name: windows-sys
    version: "0.60.2"
    sha: f2f500e4d28234f72040990ec9d39e3a6b950f9f22d3dba18416c35882612bcb
  - kind: registry
    name: windows-targets
    version: "0.53.5"
    sha: 4945f9f551b88e0d65f3db0bc25c33b8acea4d9e41163edf90dcd0b19f9069f3
  - kind: registry
    name: windows_aarch64_gnullvm
    version: "0.53.1"
    sha: a9d8416fa8b42f5c947f8482c43e7d89e73a173cead56d044f6a56104a6d1b53
  - kind: registry
    name: windows_aarch64_msvc
    version: "0.53.1"
    sha: b9d782e804c2f632e395708e99a94275910eb9100b2114651e04744e9b125006
  - kind: registry
    name: windows_i686_gnu
    version: "0.53.1"
    sha: 960e6da069d81e09becb0ca57a65220ddff016ff2d6af6a223cf372a506593a3
  - kind: registry
    name: windows_i686_gnullvm
    version: "0.53.1"
    sha: fa7359d10048f68ab8b09fa71c3daccfb0e9b559aed648a8f95469c27057180c
  - kind: registry
    name: windows_i686_msvc
    version: "0.53.1"
    sha: 1e7ac75179f18232fe9c285163565a57ef8d3c89254a30685b57d83a38d326c2
  - kind: registry
    name: windows_x86_64_gnu
    version: "0.53.1"
    sha: 9c3842cdd74a865a8066ab39c8a7a473c0778a3f29370b5fd6b4b9aa7df4a499
  - kind: registry
    name: windows_x86_64_gnullvm
    version: "0.53.1"
    sha: 0ffa179e2d07eee8ad8f57493436566c7cc30ac536a3379fdf008f47f6bb7ae1
  - kind: registry
    name: windows_x86_64_msvc
    version: "0.53.1"
    sha: d6bbff5f0aada427a1e5a6da5f1f98158182f26556f345ac9e04d36d0ebed650
  - kind: registry
    name: wit-bindgen
    version: "0.45.1"
    sha: 5c573471f125075647d03df72e026074b7203790d41351cd6edc96f46bcccd36
- kind: local
  path: files/m1n1/bootlogo_128.rgba
- kind: local
  path: files/m1n1/bootlogo_256.rgba
