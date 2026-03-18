#!/usr/bin/env bash
set -euo pipefail

FLATPAK_LIST=(
    "im.riot.Riot"
    "one.ablaze.floorp"
)

flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

for app in "${FLATPAK_LIST[@]}"; do
    if ! flatpak info --system "$app" &>/dev/null; then
        flatpak install --system --noninteractive flathub "$app"
    fi
done
