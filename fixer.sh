grep -Eiq '(^|[[:space:]])grub([[:space:]]|$)' packages.x86_64 || printf '\ngrub\n' >> packages.x86_64
grep -Eiq '(^|[[:space:]])efibootmgr([[:space:]]|$)' packages.x86_64 || printf '\nefibootmgr\n' >> packages.x86_64

sudo cp packages.x86_64 /etc/artools/profiles/solaceos/

sudo mkdir -p /etc/artools/profiles/solaceos/airootfs/usr/share/grub/cfg
sudo tee /etc/artools/profiles/solaceos/airootfs/usr/share/grub/cfg/solaceos.cfg >/dev/null <<'EOF'
# Minimal placeholder grub config for SolaceOS buildiso
set timeout=5
set default=0
EOF
