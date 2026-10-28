#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "[*] Generating APT repository in $REPO_DIR..."

# Scan packages
dpkg-scanpackages -m debs /dev/null > Packages

# Compress packages index
gzip -c9 Packages > Packages.gz
xz -c9 Packages > Packages.xz
zstd -c19 Packages > Packages.zst

# Generate Release file
cat <<EOF > Release
Origin: Yuki Repo
Label: Yuki Repo
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm64
Components: main
Description: Yuki iOS 16 Tweaks & Compatibility Fixes
Date: $(date -Ru)
MD5Sum:
 $(md5sum Packages | awk '{print $1}') $(stat -c%s Packages) Packages
 $(md5sum Packages.gz | awk '{print $1}') $(stat -c%s Packages.gz) Packages.gz
 $(md5sum Packages.xz | awk '{print $1}') $(stat -c%s Packages.xz) Packages.xz
 $(md5sum Packages.zst | awk '{print $1}') $(stat -c%s Packages.zst) Packages.zst
SHA1:
 $(sha1sum Packages | awk '{print $1}') $(stat -c%s Packages) Packages
 $(sha1sum Packages.gz | awk '{print $1}') $(stat -c%s Packages.gz) Packages.gz
 $(sha1sum Packages.xz | awk '{print $1}') $(stat -c%s Packages.xz) Packages.xz
 $(sha1sum Packages.zst | awk '{print $1}') $(stat -c%s Packages.zst) Packages.zst
SHA256:
 $(sha256sum Packages | awk '{print $1}') $(stat -c%s Packages) Packages
 $(sha256sum Packages.gz | awk '{print $1}') $(stat -c%s Packages.gz) Packages.gz
 $(sha256sum Packages.xz | awk '{print $1}') $(stat -c%s Packages.xz) Packages.xz
 $(sha256sum Packages.zst | awk '{print $1}') $(stat -c%s Packages.zst) Packages.zst
EOF

echo "[+] Repository generation complete!"
ls -la "$REPO_DIR"
