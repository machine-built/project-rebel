S=files/system
B=files/branding

# Icons
install -Dm644 $B/icons/schloss_logo.svg $S/usr/share/pixmaps/schloss.svg
install -Dm644 $B/icons/schloss_logo.svg $S/usr/share/icons/hicolor/scalable/apps/schloss.svg
for px in 16 32 64 128 256; do
  install -Dm644 $B/icons/schloss_logo${px}.png \
    $S/usr/share/icons/hicolor/${px}x${px}/apps/schloss.png
done

# Plymouth
mkdir -p $S/usr/share/plymouth/themes/schloss
cp -a $B/plymouth/. $S/usr/share/plymouth/themes/schloss/
sed -i 's|^ImageDir=.*|ImageDir=/usr/share/plymouth/themes/schloss|' \
  $S/usr/share/plymouth/themes/schloss/schloss.plymouth

# SDDM
install -Dm644 $B/sddm/BG_lockScreen.png $S/usr/share/sddm/themes/schloss/BG_lockScreen.png
mkdir -p $S/etc/sddm.conf.d $S/usr/share/sddm/themes/breeze
printf '[Theme]\nCurrent=breeze\n' > $S/etc/sddm.conf.d/10-schloss.conf
printf '[General]\ntype=image\nbackground=/usr/share/sddm/themes/schloss/BG_lockScreen.png\n' \
  > $S/usr/share/sddm/themes/breeze/theme.conf.user

# Wallpapers
W=$S/usr/share/wallpapers/Schloss
install -Dm644 $B/wallpapers/fossschloss1080.png $W/contents/images/1920x1080.png
install -Dm644 $B/wallpapers/fossschloss1440.png $W/contents/images/2560x1440.png
install -Dm644 $B/wallpapers/fossschloss1080.png $W/contents/screenshot.png
printf '{\n  "KPlugin": { "Id": "Schloss", "Name": "Schloss", "License": "GPL-3.0" },\n  "KPackageStructure": "Wallpaper/Images"\n}\n' > $W/metadata.json

# Look-and-feel
L=$S/usr/share/plasma/look-and-feel/org.almalinux.schloss.default
mkdir -p $L/contents
printf '{\n  "KPlugin": { "Id": "org.almalinux.schloss.default", "Name": "Schloss" },\n  "KPackageStructure": "Plasma/LookAndFeel"\n}\n' > $L/metadata.json
printf '[Wallpaper][org.kde.image][General]\nImage=/usr/share/wallpapers/Schloss/contents/images/1920x1080.png\n\n[Wallpaper][org.kde.image][General][ScreenLocker]\nImage=/usr/share/wallpapers/Schloss/contents/images/1920x1080.png\n' > $L/contents/defaults

# Fastfetch
install -Dm644 $B/fastfetch/schloss_config.jsonc $S/etc/xdg/fastfetch/config.jsonc
install -Dm644 $B/fastfetch/schloss_logo.txt     $S/etc/xdg/fastfetch/logo.txt

# GRUB
mkdir -p $S/usr/share/grub/themes/schloss
cp -a $B/grub-theme/. $S/usr/share/grub/themes/schloss/

# Clean up
git rm -r --cached files/branding && rm -rf files/branding
rm -f files/scripts/.branding.sh.kate-swp
git checkout files/scripts/build.sh
git checkout $(git rev-list --max-parents=0 HEAD) -- Dockerfile 2>/dev/null || true
