#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as sudo"
   exit 1
fi

apt update
apt install libsdl2-dev libgtkmm-3.0-dev libportaudio2 python3-gi libopenjp2-7 git ninja-build xorg python3-pip meson libjpeg-dev zlib1g-dev cmake extra-cmake-modules qttools5-dev qttools5-dev-tools libqt5x11extras5-dev libsdl2-dev libxi-dev libxtst-dev libx11-dev itstool gettext fbi -y

pip3 install pillow
pip3 install screeninfo

cp configFiles/gamepadcontroller.gamecontroller.amgp /home/$SUDO_USER/gamepadcontroller.gamecontroller.amgp

mkdir -p /opt/vba-m

cp configFiles/start.sh /home/$SUDO_USER

cp configFiles/usbManagment.sh /opt/vba-m

cp configFiles/rebootScreen.py /opt/vba-m

cp configFiles/newGame.glade /opt/vba-m

cp configFiles/splash.service /etc/systemd/system/

mkdir -p /usr/share/plymouth/themes/pix/

mkdir -p ConsoleGUI/newRoms

cp configFiles/splashscreen.jpg /usr/share/plymouth/themes/pix/

cp configFiles/splashscreen.jpg /opt/vba-m

chmod 755 /opt/retro/usbManagment.sh

chmod 755 /opt/retro/rebootScreen.py

mkdir -p /home/$SUDO_USER/.config/visualboyadvance-m

mkdir -p /home/$SUDO_USER/.config/antimicrox

cp configFiles/vbam.ini /home/$SUDO_USER/.config/visualboyadvance-m/

cp configFiles/antimicrox_settings.ini /home/$SUDO_USER/.config/antimicrox/

chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config/

cp /home/$SUDO_USER/GameBoy-pi/ConsoleGUI/ home/$SUDO_USER/

cd /home/$SUDO_USER

git clone https://github.com/visualboyadvance-m/visualboyadvance-m.git
cd visualboyadvance-m

./installdeps
mkdir build && cd build
cmake .. -G Ninja
ninja

mv ./visualboyadvance-m /home/$SUDO_USER/ConsoleGUI/vba-m
rm -rf /home/$SUDO_USER/visualboyadvance-m/

cd /home/$SUDO_USER

git clone https://github.com/AntiMicroX/antimicrox.git

cd antimicrox
mkdir -p build && cd build
cmake ..
cmake --build .

echo KERNEL=="sd*[!0-9]|sr*", ENV{ID_SERIAL}!="?*", SUBSYSTEMS=="usb", RUN+="/opt/vba-m/romsCopy.sh" | sudo tee --append /etc/udev/rules.d/10-usb.rules

sed -i "s/PrivateMounts=yes/PrivateMounts=no/" /lib/systemd/system/systemd-udevd.service

echo "/home/pi/start.sh 2>/dev/null" >> /home/$SUDO_USER/.bashrc

sed -i "s/$/ console=tty3 quiet splash loglevel=3 logo.nologo vt.global_cursor_default=0 plymouth.enable=0/" cmdline.txt

systemctl enable splash

reboot
