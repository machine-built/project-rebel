# ba0fde3d-bee7-4307-b97b-17d0d20aff50
# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY files/system /system_files/
COPY --chmod=0755 files/scripts /build_files/
COPY *.pub /keys/

# Base Image
FROM quay.io/almalinuxorg/atomic-desktop-kde:10@sha256:b327d8443a2b27857a66549d0df30b61938653ab2b7f0892ee030eb863604911

ARG IMAGE_NAME=schloss
ARG IMAGE_REGISTRY=PROJECT-REBEL
ARG VARIANT=ALPHA
ARG NAME_CAP=Schloss

# 1. ICONS
RUN mkdir -p /usr/share/pixmaps/${NAME}.svg

COPY files/branding/icons/${NAME}_logo.svg /usr/share/pixmaps/${NAME}.svg
COPY files/branding/icons/${NAME}_logo.svg /usr/share/icons/hicolor/scalable/apps/${NAME}.svg

RUN sed -i "s/^LOGO=.*/LOGO=${NAME}/" /usr/lib/os-release || \
    echo "LOGO=${NAME}" >> /usr/lib/os-release

# 2. PLYMOUTH SPLASH
COPY files/branding/plymouth/ /usr/share/plymouth/themes/${NAME}/

RUN plymouth-set-default-theme -R ${NAME}

# 3. SDDM THEME
COPY files/branding/sddm/ /usr/share/sddm/themes/${NAME}/
RUN mkdir -p /etc/sddm.conf.d && \
    printf '[Theme]\nCurrent=%s\n' "${NAME}" > /etc/sddm.conf.d/${NAME}.conf

# 4. WALLPAPERS
RUN mkdir -p /usr/share/wallpapers/${NAME_CAP}/contents/images

COPY files/branding/wallpapers/${NAME}_*.png /usr/share/wallpapers/${NAME_CAP}/contents/images/
RUN cd /usr/share/wallpapers/${NAME_CAP}/contents/images/ && \
    for f in ${NAME}_*.png; do mv "$f" "${f#${NAME}_}"; done

RUN mkdir -p /usr/share/plasma/look-and-feel/org.almalinux.${NAME}.default/contents && \
    cat > /usr/share/plasma/look-and-feel/org.almalinux.${NAME}.default/contents/defaults <<EOF
[Wallpaper][org.kde.image][General]
Image=/usr/share/wallpapers/${NAME_CAP}/contents/images/1920x1080.png

[Wallpaper][org.kde.image][General][ScreenLocker]
Image=/usr/share/wallpapers/${NAME_CAP}/contents/images/1920x1080.png
EOF

RUN mkdir -p /etc/xdg && \
    printf '[KDE]\nLookAndFeelPackage=org.almalinux.%s.default\n' "${NAME}" > /etc/xdg/kdeglobals

# 5. FASTFETCH
RUN mkdir -p /etc/fastfetch
COPY files/branding/fastfetch/${NAME}_logo.txt /etc/fastfetch/logo.txt
COPY files/branding/fastfetch/${NAME}_config.jsonc /etc/fastfetch/config.jsonc

# 6. GRUB THEME
RUN mkdir -p /usr/share/grub-themes/${NAME} /boot/grub2/themes/${NAME}
COPY files/branding/grub-theme/ /usr/share/grub-themes/${NAME}/
COPY files/branding/grub-theme/ /boot/grub2/themes/${NAME}/

RUN sed -i "s|^GRUB_THEME=.*|GRUB_THEME=/boot/grub2/themes/${NAME}/theme.txt|" /etc/default/grub || \
    echo "GRUB_THEME=/boot/grub2/themes/${NAME}/theme.txt" >> /etc/default/grub

RUN --mount=type=tmpfs,dst=/opt \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
