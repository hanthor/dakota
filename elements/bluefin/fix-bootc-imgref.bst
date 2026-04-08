kind: manual

description: |
  One-shot systemd service that corrects a broken bootc image reference
  created by tuna-installer versions that prefixed the targetImgref with
  an extra docker:// transport, resulting in
  "docker://docker://ghcr.io/projectbluefin/dakota:latest" being stored
  in the bootc spec and causing `bootc update` to fail with
  "invalid reference format".

sources:
- kind: local
  path: ../../files/fix-bootc-imgref

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/systemd.bst

config:
  install-commands:
  - install -Dm755 bootc-fix-imgref "%{install-root}%{libexecdir}/bootc-fix-imgref"
  - install -Dm644 bootc-fix-imgref.service "%{install-root}%{unitdir}/bootc-fix-imgref.service"
  - mkdir -p "%{install-root}%{unitdir}/multi-user.target.wants"
  - ln -sf ../bootc-fix-imgref.service "%{install-root}%{unitdir}/multi-user.target.wants/bootc-fix-imgref.service"
