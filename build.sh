#!/usr/bin/env bash
#build script might work this time, brace for impact, good luck
set -euo pipefail

WORKDIR="$HOME/solaceos-build"
RUNTIME="$WORKDIR/runtime"
OUTDIR="$WORKDIR/out"
PROFILE="/etc/artools/profiles/solaceos"

mkdir -p "$RUNTIME"
sudo mkdir -p /var/lib/artools/buildiso
sudo mount --bind "$RUNTIME" /var/lib/artools/buildiso
sudo rm -rf /var/lib/artools/buildiso/solaceos || true
rm -rf "$OUTDIR" || true
mkdir -p "$OUTDIR"

#my vm runs out of space
sudo mkdir -p "$PROFILE/airootfs"
sudo rm -rf "$PROFILE/airootfs"/*
sudo mkdir -p "$PROFILE/airootfs/etc/calamares"

sudo cp -r airootfs/. "$PROFILE/airootfs/"
sudo cp packages.x86_64 "$PROFILE/"
sudo cp profiledef.sh "$PROFILE/"
sudo cp -r calamares/. "$PROFILE/airootfs/etc/calamares/"

echo "grub" >> "$PROFILE/packages.x86_64"

sudo buildiso -p solaceos -w "$WORKDIR/workdir" -o "$OUTDIR"
mv /var/cache/isos/solaceos-*.iso out/ 2>/dev/null || true
echo "Built ISOs (if any) in: $OUTDIR"
