#!/usr/bin/env bash
set -euo pipefail

STAMP="/var/lib/rebel-flatpak-done"

# Skip if already completed
if [ -f "$STAMP" ]; then
    exit 0
fi

flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

FLATPAK_LIST=(
    "im.riot.Riot"
    "one.ablaze.floorp"
)

FAILED=0
for app in "${FLATPAK_LIST[@]}"; do
    if ! flatpak info --system "$app" &>/dev/null; then
        if ! flatpak install --system --noninteractive flathub "$app"; then
            FAILED=1
        fi
    fi
done

# stamp if successful
if [ "$FAILED" -eq 0 ]; then
    touch "$STAMP"
fi
