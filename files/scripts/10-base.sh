#!/usr/bin/env bash

set -xeuo pipefail

mkdir -p /var/lib/rpm-state
# Import RPM Fusion keys
dnf install -y distribution-gpg-keys
rpmkeys --import \
    /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-el-$(rpm -E %rhel) \
    /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-el-$(rpm -E %rhel)

# 3. Add RPM Fusion free + nonfree for EL10
dnf --setopt=localpkg_gpgcheck=1 install -y \
      https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

dnf install -y plasma-login-manager

# Start installing utilities and tools
dnf install -y \
    ncdu \
    powertop \
    htop \
    fastfetch \
	systemd-{resolved,container,oomd} \
    jetbrains-mono-fonts-all \
    libcamera{,-{v4l2,gstreamer,tools}} \
    gstreamer1-plugins-{base,bad-free-libs} \
    lame{,-libs} \
    libjxl

# Now let's go for the main packages
dnf -y install \
    buildah \
    distrobox

dnf config-manager --save \
  --setopt=exclude=PackageKit,PackageKit-command-not-found,rootfiles,firefox

dnf install -y sssd sssd-idp oddjob-mkhomedir authselect
authselect select sssd with-mkhomedir --force
systemctl enable oddjobd.service sssd.service

#dnf install -y alsa-sof-firmware

dnf install -y thermald

dnf install -y intel-media-driver

dnf install -y kmail

# Calendar/contacts/tasks stack (EPEL)
dnf install -y \
    merkuro \
    korganizer \
    kaddressbook \
    kdepim-runtime \
    kdepim-addons

systemctl enable thermald.service

# enable fwupd service
systemctl enable fwupd.service

#hostname creation for Beszel tracking
chmod +x /usr/libexec/set-hostname.sh
systemctl enable rebel-set-hostname.service

#systemctl enable opt.mount
systemctl enable rebel-timedate-config.service

#Element kwallet override
systemctl enable rebel-flatpak-overrides.service

# Enable polkit rules for fingerprint sensors via fprintd
authselect enable-feature with-fingerprint

rm -f /etc/systemd/system/multi-user.target.wants/kdump.service

sed -i 's,AlmaLinux,RebelLinux,g' /usr/lib/os-release
# sed -i 's,ID="almalinux",ID="rebel",g' /usr/lib/os-release
# sed -i 's,rhel,almalinux rhel,g' /usr/lib/os-release
# sed -i 's,https://almalinux.org/,g' /usr/lib/os-release
# sed -i 's,https://wiki.almalinux.org/,g' /usr/lib/os-release
# sed -i 's,https://bugs.almalinux.org/,g' /usr/lib/os-release

echo "Hello, Schloss Linux world!."
