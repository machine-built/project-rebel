#!/usr/bin/env bash

set -xeuo pipefail

# Install system Flatpaks
cat << 'EOF' >> /etc/flatpak/default-flatpaks/system/install
com.github.tchx84.Flatseal
io.github.flattool.Warehouse
org.videolan.VLC
im.riot.Riot
one.ablaze.floorp
EOF

# Remove system Flatpaks
cat << 'EOF' >> /etc/flatpak/default-flatpaks/system/remove
org.gnome.Extensions
EOF

