#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "=== Generating APT Repository for Sileo & Zebra ==="

# 1. Scan packages
dpkg-scanpackages -m debs /dev/null > Packages
echo "Generated Packages"

# 2. Compress Packages in all formats
gzip -c9 Packages > Packages.gz
bzip2 -c9 Packages > Packages.bz2
xz -c9 Packages > Packages.xz
zstd -c19 Packages > Packages.zst
echo "Compressed Packages (.gz, .bz2, .xz, .zst)"

# 3. Generate Release file
python3 - << 'EOF'
import hashlib
import os

files = ['Packages', 'Packages.gz', 'Packages.bz2', 'Packages.xz', 'Packages.zst']

def get_hashes(filepath):
    with open(filepath, 'rb') as f:
        data = f.read()
    return (
        hashlib.md5(data).hexdigest(),
        hashlib.sha1(data).hexdigest(),
        hashlib.sha256(data).hexdigest(),
        len(data)
    )

release_content = """Origin: Yuki Repo
Label: Yuki Repo
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm64 iphoneos-arm64e
Components: main
Description: Yuki-1018's Jailbreak Repository - High-Fidelity iOS 17/18+ Compatibility Tweaks (Compat16)
"""

md5_lines = []
sha1_lines = []
sha256_lines = []

for filename in files:
    if os.path.exists(filename):
        md5, sha1, sha256, size = get_hashes(filename)
        md5_lines.append(f" {md5} {size:16d} {filename}")
        sha1_lines.append(f" {sha1} {size:16d} {filename}")
        sha256_lines.append(f" {sha256} {size:16d} {filename}")

release_content += "MD5Sum:\n" + "\n".join(md5_lines) + "\n"
release_content += "SHA1:\n" + "\n".join(sha1_lines) + "\n"
release_content += "SHA256:\n" + "\n".join(sha256_lines) + "\n"

with open("Release", "w", encoding="utf-8") as f:
    f.write(release_content)

print("Generated Release file with MD5, SHA1, and SHA256 sums.")
EOF

echo "Repository generation complete!"
