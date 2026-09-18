#!/usr/bin/env bash
# Schloss branding config
set -euxo pipefail

NAME="${NAME:-schloss}"
NAME_CAP="${NAME_CAP:-Schloss}"
VARIANT="${VARIANT:-ALPHA}"

# ---------------------------------------------------------------- ICONS
if grep -q '^LOGO=' /usr/lib/os-release; then
    sed -i "s/^LOGO=.*/LOGO=${NAME}/" /usr/lib/os-release
else
    echo "LOGO=${NAME}" >> /usr/lib/os-release
fi

# Surfaced by fastfetch's os module as {6} / {7}
sed -i '/^VARIANT/d' /usr/lib/os-release
{
    printf 'VARIANT="%s"\n' "${VARIANT}"
#    printf 'VARIANT_ID=%s\n' "$(echo "${VARIANT}" | tr '[:upper:]' '[:lower:]')"
} >> /usr/lib/os-release

# ------------------------------------------------------- PLYMOUTH SPLASH
#command -v plymouth-set-default-theme >/dev/null

# mkdir -p "/usr/share/plymouth/themes/${NAME}"
# cp -a "${BRANDING}/plymouth/." "/usr/share/plymouth/themes/${NAME}/"

# Source file ships a doubled slash in ImageDir; normalise it.
#sed -i "s|^ImageDir=.*|ImageDir=/usr/share/plymouth/themes/${NAME}|" \
#    "/usr/share/plymouth/themes/${NAME}/${NAME}.plymouth"

#plymouth-set-default-theme "${NAME}"

# ------------------------------------------------------------ WALLPAPERS
# Image files ship via files/system/usr/share/wallpapers/. This section only
# points the distro defaults (owned by kde-settings RPMs) at them.
command -v kwriteconfig6 >/dev/null

WP="${NAME_CAP}"          # directory name under /usr/share/wallpapers (case-sensitive)
LNF_ID="org.almalinux.${NAME}.default"
KDEPROFILE="/usr/share/kde-settings/kde-profile/default/xdg"
WPGROUP=(--group Greeter --group Wallpaper --group org.kde.image --group General)

# Fail the build here rather than ship a broken default
test -f "/usr/share/wallpapers/${WP}/metadata.json"

for wp in "${WP}" foss; do
    compgen -G "/usr/share/wallpapers/${wp}/contents/images/[0-9]*x[0-9]*.*" >/dev/null \
        || { echo "ERROR: no images under /usr/share/wallpapers/${wp}/contents/images/" >&2; exit 1; }
done

test -f "/usr/share/plasma/look-and-feel/${LNF_ID}/contents/defaults"

# Desktop: default global theme (its contents/defaults names the wallpaper)
#kwriteconfig6 --file "${KDEPROFILE}/kdeglobals" --group KDE \
#    --key LookAndFeelPackage "${LNF_ID}"

# Lock screen
#kwriteconfig6 --file "${KDEPROFILE}/kscreenlockerrc" "${WPGROUP[@]}" \
#    --key Image "file:///usr/share/wallpapers/${WP}"

PLM_DEFAULTS=/usr/lib/plasmalogin/defaults.conf
rpm -q plasma-login-manager        # fail loudly if the DM changes under us again
ls -l "${PLM_DEFAULTS}" || true    # log whether an RPM shipped it, and its mode
kwriteconfig6 --file "${PLM_DEFAULTS}" "${WPGROUP[@]}" \
    --key Image "file:///usr/share/wallpapers/${WP}"
chmod 0644 "${PLM_DEFAULTS}"       # greeter runs as user 'plasmalogin'
cat "${PLM_DEFAULTS}"              # evidence in build.log

#[Wallpaper][org.kde.image][General][ScreenLocker]
#Image=${WPDIR}/contents/images/1920x1080.png
#DEFAULTS


# ------------------------------------------------------------- FASTFETCH
# XDG search path — /etc/fastfetch is NOT read by fastfetch.
#install -Dm0644 "${BRANDING}/fastfetch/${NAME}_logo.txt" \
#    /etc/xdg/fastfetch/logo.txt
#install -Dm0644 "${BRANDING}/fastfetch/${NAME}_config.jsonc" \
#    /etc/xdg/fastfetch/config.jsonc

# ---------------------------------------------------------- INITRAMFS
#kver="$(cd /usr/lib/modules && echo * | awk '{print $1}')"
#dracut --no-hostonly --reproducible -vf \
#    "/usr/lib/modules/${kver}/initramfs.img" "${kver}"
