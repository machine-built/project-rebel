#!/usr/bin/env bash
# Schloss OS branding — applied during image build.
# Invoked from the Dockerfile as: bash /ctx/scripts/branding.sh
#
# Build args (NAME, NAME_CAP, VARIANT, IMAGE_REGISTRY) arrive as environment
# variables. Defaults below keep the script runnable standalone for testing.
set -euxo pipefail

NAME="${NAME:-schloss}"
NAME_CAP="${NAME_CAP:-Schloss}"
VARIANT="${VARIANT:-ALPHA}"

BRANDING="${BRANDING:-/ctx/branding}"

# ---------------------------------------------------------------- 1. ICONS
install -Dm0644 "${BRANDING}/icons/${NAME}_logo.svg" \
    "/usr/share/pixmaps/${NAME}.svg"
install -Dm0644 "${BRANDING}/icons/${NAME}_logo.svg" \
    "/usr/share/icons/hicolor/scalable/apps/${NAME}.svg"

for px in 16 32 64 128 256; do
    install -Dm0644 "${BRANDING}/icons/${NAME}_logo${px}.png" \
        "/usr/share/icons/hicolor/${px}x${px}/apps/${NAME}.png"
done

if grep -q '^LOGO=' /usr/lib/os-release; then
    sed -i "s/^LOGO=.*/LOGO=${NAME}/" /usr/lib/os-release
else
    echo "LOGO=${NAME}" >> /usr/lib/os-release
fi

# Surfaced by fastfetch's os module as {6} / {7}
sed -i '/^VARIANT/d' /usr/lib/os-release
{
    printf 'VARIANT="%s"\n' "${VARIANT}"
    printf 'VARIANT_ID=%s\n' "$(echo "${VARIANT}" | tr '[:upper:]' '[:lower:]')"
} >> /usr/lib/os-release

# ------------------------------------------------------- 2. PLYMOUTH SPLASH
command -v plymouth-set-default-theme >/dev/null

mkdir -p "/usr/share/plymouth/themes/${NAME}"
cp -a "${BRANDING}/plymouth/." "/usr/share/plymouth/themes/${NAME}/"

# Source file ships a doubled slash in ImageDir; normalise it.
sed -i "s|^ImageDir=.*|ImageDir=/usr/share/plymouth/themes/${NAME}|" \
    "/usr/share/plymouth/themes/${NAME}/${NAME}.plymouth"

plymouth-set-default-theme "${NAME}"

# ------------------------------------------------------------ 3. SDDM THEME
# Override Breeze's background rather than shipping an incomplete theme.
# A real custom theme needs Main.qml + metadata.desktop with [SddmGreeterTheme].
install -Dm0644 "${BRANDING}/sddm/BG_lockScreen.png" \
    "/usr/share/sddm/themes/${NAME}/BG_lockScreen.png"

mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=breeze\n' > "/etc/sddm.conf.d/10-${NAME}.conf"

cat > /usr/share/sddm/themes/breeze/theme.conf.user <<SDDM
[General]
type=image
background=/usr/share/sddm/themes/${NAME}/BG_lockScreen.png
SDDM

# ------------------------------------------------------------ 4. WALLPAPERS
WPDIR="/usr/share/wallpapers/${NAME_CAP}"

install -Dm0644 "${BRANDING}/wallpapers/fossschloss1080.png" \
    "${WPDIR}/contents/images/1920x1080.png"
install -Dm0644 "${BRANDING}/wallpapers/fossschloss1440.png" \
    "${WPDIR}/contents/images/2560x1440.png"
install -Dm0644 "${BRANDING}/wallpapers/fossschloss1080.png" \
    "${WPDIR}/contents/screenshot.png"

cat > "${WPDIR}/metadata.json" <<WP
{
  "KPlugin": {
    "Id": "${NAME_CAP}",
    "Name": "${NAME_CAP}",
    "License": "GPL-3.0"
  },
  "KPackageStructure": "Wallpaper/Images"
}
WP

LNF="/usr/share/plasma/look-and-feel/org.almalinux.${NAME}.default"
mkdir -p "${LNF}/contents"

cat > "${LNF}/metadata.json" <<LNFMETA
{
  "KPlugin": {
    "Id": "org.almalinux.${NAME}.default",
    "Name": "${NAME_CAP}"
  },
  "KPackageStructure": "Plasma/LookAndFeel"
}
LNFMETA

cat > "${LNF}/contents/defaults" <<DEFAULTS
[Wallpaper][org.kde.image][General]
Image=${WPDIR}/contents/images/1920x1080.png

[Wallpaper][org.kde.image][General][ScreenLocker]
Image=${WPDIR}/contents/images/1920x1080.png
DEFAULTS

# Append rather than clobber whatever the base image ships.
mkdir -p /etc/xdg
if grep -q '^\[KDE\]' /etc/xdg/kdeglobals 2>/dev/null; then
    sed -i "/^\[KDE\]/a LookAndFeelPackage=org.almalinux.${NAME}.default" \
        /etc/xdg/kdeglobals
else
    printf '\n[KDE]\nLookAndFeelPackage=org.almalinux.%s.default\n' "${NAME}" \
        >> /etc/xdg/kdeglobals
fi

# ------------------------------------------------------------- 5. FASTFETCH
# XDG search path — /etc/fastfetch is NOT read by fastfetch.
install -Dm0644 "${BRANDING}/fastfetch/${NAME}_logo.txt" \
    /etc/xdg/fastfetch/logo.txt
install -Dm0644 "${BRANDING}/fastfetch/${NAME}_config.jsonc" \
    /etc/xdg/fastfetch/config.jsonc

# ------------------------------------------------------------ 6. GRUB THEME
# /usr only. bootc forbids container content in /boot, and `bootc container
# lint` will fail the build if you put it there.
mkdir -p "/usr/share/grub/themes/${NAME}"
cp -a "${BRANDING}/grub-theme/." "/usr/share/grub/themes/${NAME}/"

if grep -q '^GRUB_THEME=' /etc/default/grub; then
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=/usr/share/grub/themes/${NAME}/theme.txt|" \
        /etc/default/grub
else
    echo "GRUB_THEME=/usr/share/grub/themes/${NAME}/theme.txt" >> /etc/default/grub
fi

# ---------------------------------------------------------- 7. INITRAMFS
# Must run last, after the plymouth theme is registered. Pass the kernel
# version explicitly — dracut otherwise probes the running kernel and fails.
kver="$(cd /usr/lib/modules && echo *)"
dracut --no-hostonly --reproducible -vf \
    "/usr/lib/modules/${kver}/initramfs.img" "${kver}"
