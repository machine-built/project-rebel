#!/usr/bin/env bash

set -xeuo pipefail

mkdir -p /var/lib/rpm-state
# Import RPM Fusion keys
dnf install -y distribution-gpg-keys && \
    rpmkeys --import \
      /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-el-$(rpm -E %rhel) \
      /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-el-$(rpm -E %rhel)

# 3. Add RPM Fusion free + nonfree for EL10
dnf --setopt=localpkg_gpgcheck=1 install -y \
      https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

dnf config-manager --save \
  --setopt=exclude=PackageKit,PackageKit-command-not-found,rootfiles,firefox

#dnf install -y gdm
#systemctl disable sddm.service
#systemctl enable gdm.service

dnf install -y sssd sssd-idp oddjob-mkhomedir authselect
authselect select sssd with-mkhomedir --force
systemctl enable oddjobd.service sssd.service

dnf install -y git-core make distrobox

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

dnf install -y fastfetch


systemctl enable thermald.service

# enable fwupd service
systemctl enable fwupd.service

chmod +x /usr/libexec/install-flatpaks.sh
systemctl enable rebel-flatpak-install.service

#systemctl enable opt.mount

systemctl enable rebel-timedate-config.service

rm -f /etc/systemd/system/multi-user.target.wants/kdump.service

sed -i 's,AlmaLinux,RebelLinux,g' /usr/lib/os-release
# sed -i 's,ID="almalinux",ID="rebel",g' /usr/lib/os-release
# sed -i 's,rhel,almalinux rhel,g' /usr/lib/os-release
# sed -i 's,https://almalinux.org/,g' /usr/lib/os-release
# sed -i 's,https://wiki.almalinux.org/,g' /usr/lib/os-release
# sed -i 's,https://bugs.almalinux.org/,g' /usr/lib/os-release

echo "Hello, Schloss Linux world!."
