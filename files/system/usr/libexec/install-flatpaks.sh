#!/usr/bin/env bash
set -euo pipefail

FLATPAK_LIST=(
    "io.github.kolunmi.Bazaar"
)

flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

for app in "${FLATPAK_LIST[@]}"; do
    if ! flatpak info --system "$app" &>/dev/null; then
        flatpak install --system --noninteractive flathub "$app"
    fi
done
