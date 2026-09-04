#!/usr/bin/env bash
# Schloss branding config
set -euxo pipefail

NAME="${NAME:-schloss}"
NAME_CAP="${NAME_CAP:-Schloss}"
VARIANT="${VARIANT:-ALPHA}"

# ---------------------------------------------------------------- 1. ICONS
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

# ------------------------------------------------------- 2. PLYMOUTH SPLASH
command -v plymouth-set-default-theme >/dev/null

# mkdir -p "/usr/share/plymouth/themes/${NAME}"
# cp -a "${BRANDING}/plymouth/." "/usr/share/plymouth/themes/${NAME}/"

# Source file ships a doubled slash in ImageDir; normalise it.
#sed -i "s|^ImageDir=.*|ImageDir=/usr/share/plymouth/themes/${NAME}|" \
#    "/usr/share/plymouth/themes/${NAME}/${NAME}.plymouth"

plymouth-set-default-theme "${NAME}"

# ------------------------------------------------------------ 3. SDDM THEME
printf '[Theme]\nCurrent=breeze\n' > "/etc/sddm.conf.d/10-${NAME}.conf"

cat > /usr/share/sddm/themes/breeze/theme.conf.user <<SDDM
[General]
type=image
background=/usr/share/sddm/themes/${NAME}/background-tile.png
SDDM

# ------------------------------------------------------------ 4. WALLPAPERS
WPDIR="/usr/share/wallpapers/${NAME_CAP}"

#install -Dm0644 "${BRANDING}/wallpapers/fossschloss1080.png" \
#    "${WPDIR}/contents/images/1920x1080.png"
#install -Dm0644 "${BRANDING}/wallpapers/fossschloss1440.png" \
#    "${WPDIR}/contents/images/2560x1440.png"
#install -Dm0644 "${BRANDING}/wallpapers/fossschloss1080.png" \
#    "${WPDIR}/contents/screenshot.png"

LNF="/usr/share/plasma/look-and-feel/org.almalinux.${NAME}.default"
#mkdir -p "${LNF}/contents"

#cat > "${LNF}/contents/defaults" <<DEFAULTS
#[Wallpaper][org.kde.image][General]
#Image=Schloss

#[Wallpaper][org.kde.image][General][ScreenLocker]
#Image=${WPDIR}/contents/images/1920x1080.png
#DEFAULTS


# ------------------------------------------------------------- 5. FASTFETCH
# XDG search path — /etc/fastfetch is NOT read by fastfetch.
#install -Dm0644 "${BRANDING}/fastfetch/${NAME}_logo.txt" \
#    /etc/xdg/fastfetch/logo.txt
#install -Dm0644 "${BRANDING}/fastfetch/${NAME}_config.jsonc" \
#    /etc/xdg/fastfetch/config.jsonc

# ---------------------------------------------------------- 7. INITRAMFS
kver="$(cd /usr/lib/modules && echo *)"
dracut --no-hostonly --reproducible -vf \
    "/usr/lib/modules/${kver}/initramfs.img" "${kver}"
