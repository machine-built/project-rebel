#!/usr/bin/env bash

set -xeuo pipefail

# Start customizing your image here

# Examples:
# dnf install -y 'dnf-command(config-manager)'
# dnf config-manager --set-enabled crb

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

# install linux firmware
dnf install -y linux-firmware

# install microcode and fwupd
dnf install -y microcode_ctl fwupd

# install intel-audio-firmware
dnf install -y intel-audio-firmware

dnf install -y alsa-sof-firmware

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

chmod +x /usr/libexec/install-flatpaks.sh
systemctl enable rebel-flatpak-install.service

systemctl enable opt.mount

systemctl enable rebel-timedate-config.service

rm -f /etc/systemd/system/multi-user.target.wants/kdump.service

sed -i 's,AlmaLinux,RebelLinux,g' /usr/lib/os-release
# sed -i 's,ID="almalinux",ID="rebel",g' /usr/lib/os-release
# sed -i 's,rhel,almalinux rhel,g' /usr/lib/os-release
# sed -i 's,https://almalinux.org/,g' /usr/lib/os-release
# sed -i 's,https://wiki.almalinux.org/,g' /usr/lib/os-release
# sed -i 's,https://bugs.almalinux.org/,g' /usr/lib/os-release

echo "Hello, Atomic AlmaLinux respin world!."
