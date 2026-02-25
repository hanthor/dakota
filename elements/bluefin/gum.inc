build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" gum
    - |
      install -Dm644 -t "%{install-root}%{datadir}/bash-completion/completions" completions/gum.bash
      install -Dm644 -t "%{install-root}%{datadir}/zsh/site-functions" completions/gum.zsh
      install -Dm644 -t "%{install-root}%{datadir}/fish/vendor_completions.d" completions/gum.fish
    - |
      install -Dm644 -t "%{install-root}%{datadir}/man/man1" manpages/gum.1.gz
    - |
      %{install-extra}
