build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" glow
    - |
      install -Dm644 -t "%{install-root}%{datadir}/bash-completion/completions" completions/glow.bash
      install -Dm644 -t "%{install-root}%{datadir}/zsh/site-functions" completions/glow.zsh
      install -Dm644 -t "%{install-root}%{datadir}/fish/vendor_completions.d" completions/glow.fish
    - |
      install -Dm644 -t "%{install-root}%{datadir}/man/man1" manpages/glow.1.gz
    - |
      %{install-extra}
