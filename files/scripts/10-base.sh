#!/usr/bin/env bash

set -xeuo pipefail

# Start customizing your image here

# Examples:
# dnf install -y 'dnf-command(config-manager)'
# dnf config-manager --set-enabled crb

dnf config-manager --save \
  --setopt=exclude=PackageKit,PackageKit-command-not-found,rootfiles,firefox

# install linux firmware
dnf install -y linux-firmware

# install microcode and fwupd
dnf install -y microcode_ctl fwupd

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
