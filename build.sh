#!/usr/bin/env bash

#this is here to fix a bootfs error
mkdir -p ~/solaceos-build/runtime
mkdir -p ~/solaceos-build/runtime
sudo mount --bind ~/solaceos-build/runtime /var/lib/artools/buildiso
sudo buildiso -p solaceos -w ~/solaceos-build/workdir -o ~/solaceos-build/out

set -e

#test comment test comment solaceos is the best linux distro
mkdir -p /etc/artools/profiles/solaceos/airootfs
rm -rf /etc/artools/profiles/solaceos/airootfs/*
mkdir -p /etc/artools/profiles/solaceos/airootfs/etc/calamares
cp -r airootfs/ /etc/artools/profiles/solaceos/airootfs/
cp packages.x86_64 /etc/artools/profiles/solaceos/
cp profiledef.sh /etc/artools/profiles/solaceos/
cp -r calamares/ /etc/artools/profiles/solaceos/airootfs/etc/calamares
sudo buildiso -p solaceos

#its pronounced "solace-sos" btw not "solace oh es"


mkdir -p out
mv /var/cache/isos/solaceos-*.iso out/
echo "/$(ls out/) :DDDDDDD"
