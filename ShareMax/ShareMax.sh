#!/bin/sh
# https://stackoverflow.com/questions/3738173/why-does-pyusb-libusb-require-root-sudo-permissions-on-linux#8582398
hidepath=.ShareMax
udevrule="$hidepath/99-ShareMax.rules"
screenmain="$hidepath/ScreenMain"
sharemax="/opt/ShareMax/"
systemduser="/etc/systemd/user/"
udevrules="/etc/udev/rules.d/"
platform=$(arch)
current_arch=""

if [ -z "${platform##*aarch*}" ]; then
    echo "current arch: ARM"
    current_arch="ARM"
fi

if [ -z "${platform##*x86*}" ]; then
    echo "current arch: x86_64"
    current_arch="X86"
fi

edevicemonitor="$hidepath/$current_arch/EDeviceMonitor"
edevicemonitorservice="$hidepath/EDeviceMonitor.service"

systemctl --user stop EDeviceMonitor

user=$(whoami)

sudo cp -f "$udevrule" "$udevrules"

sudo adduser $user plugdev

sudo udevadm control --reload
sudo udevadm trigger

sudo rm -rf "$sharemax"
sudo mkdir "$sharemax"
sudo cp -f "$edevicemonitor" "$sharemax"
sudo chmod 755 "$sharemax/EDeviceMonitor"
sudo cp -f "$edevicemonitorservice" "$systemduser"

systemctl --user daemon-reload
systemctl --user start EDeviceMonitor
systemctl --user enable EDeviceMonitor

echo '投屏器初始化成功，请拔插投屏器之后开始投屏'
read -p "按任意键来关闭此窗口"
