# Make sure the buildiso temp dir exists (may differ if build name changed)
BUILDROOT="/var/lib/artools/buildiso/solaceos/artix/rootfs"
sudo mkdir -p "$BUILDROOT/usr/share/grub/cfg"

# Create a minimal placeholder grub cfg so cp glob has a match
sudo tee "$BUILDROOT/usr/share/grub/cfg/solaceos-placeholder.cfg" >/dev/null <<'EOF'
# Minimal placeholder grub config for SolaceOS buildiso
set timeout=5
set default=0
EOF

# Also create the same placeholder in the profile airootfs (so future builds see it)
PROFILE="/etc/artools/profiles/solaceos"
sudo mkdir -p "$PROFILE/airootfs/usr/share/grub/cfg"
sudo tee "$PROFILE/airootfs/usr/share/grub/cfg/solaceos-placeholder.cfg" >/dev/null <<'EOF'
# Minimal placeholder grub config for SolaceOS buildiso (profile fallback)
set timeout=5
set default=0
EOF
