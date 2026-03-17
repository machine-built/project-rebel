#!/usr/bin/env bash

set -xeuo pipefail

# Start customizing your image here

# Examples:
# dnf install -y 'dnf-command(config-manager)'
# dnf config-manager --set-enabled crb

# Enable CRB (required dependency for many EPEL packages)
dnf install -y 'dnf-command(config-manager)'
dnf config-manager --set-enabled crb

# Install EPEL
dnf install -y epel-release

# Install flatpak
dnf install -y flatpak

# Add Flathub remote (system-wide)
flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

systemctl enable rebel-flatpak-install.service

echo "Hello, Atomic AlmaLinux respin world!."
