#!/usr/bin/env bash
#HOPEFULLY this works
set -euo pipefail
IFS=$'\n\t'

WORKDIR="$HOME/solaceos-build"
RUNTIME="$WORKDIR/runtime"
OUTDIR="$WORKDIR/out"
PROFILE="/etc/artools/profiles/solaceos"
AIROOTFS_SRC="airootfs"
CALAMARES_SRC="calamares"
PKG_FILE="packages.x86_64"
PROFILEDEF="profiledef.sh"

info(){ printf '\e[1;34m[INFO]\e[0m %s\n' "$*"; }
warn(){ printf '\e[1;33m[WARN]\e[0m %s\n' "$*"; }
err(){  printf '\e[1;31m[ERROR]\e[0m %s\n' "$*"; exit 1; }

if ! sudo -v; then
  err "You need sudo privileges to run this script."
fi

cleanup() {
  info "Cleaning up..."
  if mountpoint -q /var/lib/artools/buildiso; then
    sudo umount /var/lib/artools/buildiso || warn "Failed to unmount /var/lib/artools/buildiso"
  fi
}
trap cleanup EXIT

info "Preparing build directories..."
mkdir -p "$WORKDIR" "$RUNTIME" "$OUTDIR"
sudo mkdir -p /var/lib/artools/buildiso

info "Binding runtime -> /var/lib/artools/buildiso"
sudo mount --bind "$RUNTIME" /var/lib/artools/buildiso

info "Resetting profile target: $PROFILE"
sudo mkdir -p "$PROFILE/airootfs"
sudo rm -rf "$PROFILE/airootfs"/*
sudo mkdir -p "$PROFILE/airootfs/etc/calamares"

[ -d "$AIROOTFS_SRC" ] || err "Missing local airootfs directory: $AIROOTFS_SRC"
[ -f "$PKG_FILE" ] || err "Missing $PKG_FILE in current dir"
[ -f "$PROFILEDEF" ] || err "Missing $PROFILEDEF in current dir"
[ -d "$CALAMARES_SRC" ] || warn "calamares dir not found locally; continuing without it"

info "Copying airootfs -> $PROFILE/airootfs (preserving hidden files)"
if command -v rsync >/dev/null 2>&1; then
  sudo rsync -a --delete "$AIROOTFS_SRC"/ "$PROFILE/airootfs"/
else
  sudo cp -a "$AIROOTFS_SRC"/. "$PROFILE/airootfs"/
fi

info "Copying calamares (if present)"
if [ -d "$CALAMARES_SRC" ]; then
  if command -v rsync >/dev/null 2>&1; then
    sudo rsync -a --delete "$CALAMARES_SRC"/ "$PROFILE/airootfs/etc/calamares"/
  else
    sudo cp -a "$CALAMARES_SRC"/. "$PROFILE/airootfs/etc/calamares"/
  fi
fi

info "Copying package list and profiledef"
sudo cp "$PKG_FILE" "$PROFILE/"
sudo cp "$PROFILEDEF" "$PROFILE/"

if ! grep -Eiq '(^|\s)grub($|\s)' "$PKG_FILE"; then
  warn "packages.x86_64 does NOT list 'grub'. The build may lack /usr/share/grub/cfg files."
  warn "If you target UEFI, consider adding 'grub' and 'efibootmgr' to $PKG_FILE
  echo "grub" | sudo tee -a "$PROFILE/$PKG_FILE" >/dev/null
fi

info "Cleaning previous buildiso state if present"
sudo rm -rf /var/lib/artools/buildiso/solaceos || true
rm -rf "$OUTDIR"/* || true
mkdir -p "$OUTDIR"

info "Running buildiso"
sudo buildiso -p solaceos -w "$WORKDIR/workdir" -o "$OUTDIR"

if compgen -G "/var/cache/isos/solaceos-*.iso" >/dev/null; then
  info "Moving built iso from /var/cache/isos to $OUTDIR"
  sudo mv /var/cache/isos/solaceos-*.iso "$OUTDIR"/ || warn "mv failed"
fi

info "ISO in $OUTDIR"
ls -lh "$OUTDIR" || true
