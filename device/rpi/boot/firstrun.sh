#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_hostname ziloo-test
else
   echo ziloo-test >/etc/hostname
   sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\tziloo-test/g" /etc/hosts
fi
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom enable_ssh -k 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEAhpWPDI8I86OL3x2jegBAgNrxVJG9jrBJL+cd7SHVBw9KDs/D7qrGl29TL37L63VW5Ac2vRTeDI4ZcOXi3O8k9msPSF62a2NOkPeWdiL+ijQVpWq9IlYvYGt1SWPgTMDYh5uTG3mguwcS4JjipGKegWVvtS3d0op3bUzN3Nw51ugg4cYmFHyjGERCuoqtr+qDbJjKII04038CcKjNqxtSclzXk6dpHGcnmUVlk/Zd1R4A0DDkhdNx/XgLJf7VonVsUr9uqVCQMTtCOTjWeJ5VjjExamlEFHkoc5cooiCUseH4m37vEmRcjtw2Amo6ZCxM08DdAjhi8Bg4tTyqNZa4MvVJxIYNzgrtzwkvSRagHlBumSPSXUt2xoM2n5XAy+9KSypwzV4qRoa3iDTfLRNAHJRSh2G9ENooXCl32IhwlwmNiZRcGwUIWkRiD8A86RQtK00tu+sapFSRDuyBmr54kZWcUiJdoHC9dfI0wRQkmxqFAYb7kaOjoL8nD1AcydqUAKytK6DqB+k2ZfW9ciYxNmetKup4+6ha0eZ2g9iJfX2/7fWJm3kNOodMoDNEjEXmMEgM2tXQL1A4tgq520kk9tF+IZIx5adMWLViG8QWLEk4dkDGgQFJAnz/hMYL3D2h0KeM+lFov2nJYc37/EFS8xgupojRRqu078k8vDWIQ== henrik@thepia.com'
else
   install -o "$FIRSTUSER" -m 700 -d "$FIRSTUSERHOME/.ssh"
   install -o "$FIRSTUSER" -m 600 <(printf "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEAhpWPDI8I86OL3x2jegBAgNrxVJG9jrBJL+cd7SHVBw9KDs/D7qrGl29TL37L63VW5Ac2vRTeDI4ZcOXi3O8k9msPSF62a2NOkPeWdiL+ijQVpWq9IlYvYGt1SWPgTMDYh5uTG3mguwcS4JjipGKegWVvtS3d0op3bUzN3Nw51ugg4cYmFHyjGERCuoqtr+qDbJjKII04038CcKjNqxtSclzXk6dpHGcnmUVlk/Zd1R4A0DDkhdNx/XgLJf7VonVsUr9uqVCQMTtCOTjWeJ5VjjExamlEFHkoc5cooiCUseH4m37vEmRcjtw2Amo6ZCxM08DdAjhi8Bg4tTyqNZa4MvVJxIYNzgrtzwkvSRagHlBumSPSXUt2xoM2n5XAy+9KSypwzV4qRoa3iDTfLRNAHJRSh2G9ENooXCl32IhwlwmNiZRcGwUIWkRiD8A86RQtK00tu+sapFSRDuyBmr54kZWcUiJdoHC9dfI0wRQkmxqFAYb7kaOjoL8nD1AcydqUAKytK6DqB+k2ZfW9ciYxNmetKup4+6ha0eZ2g9iJfX2/7fWJm3kNOodMoDNEjEXmMEgM2tXQL1A4tgq520kk9tF+IZIx5adMWLViG8QWLEk4dkDGgQFJAnz/hMYL3D2h0KeM+lFov2nJYc37/EFS8xgupojRRqu078k8vDWIQ== henrik@thepia.com") "$FIRSTUSERHOME/.ssh/authorized_keys"
   echo 'PasswordAuthentication no' >>/etc/ssh/sshd_config
   systemctl enable ssh
fi
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'pi' '$5$pZSNoCk68i$I1Nn/QmDV0s0l4kbl8onm3vQ.jHRYFFlHWhAyFmWmWA'
else
   echo "$FIRSTUSER:"'$5$pZSNoCk68i$I1Nn/QmDV0s0l4kbl8onm3vQ.jHRYFFlHWhAyFmWmWA' | chpasswd -e
   if [ "$FIRSTUSER" != "pi" ]; then
      usermod -l "pi" "$FIRSTUSER"
      usermod -m -d "/home/pi" "pi"
      groupmod -n "pi" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=pi/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/pi/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /pi /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_wlan 'Experiential' '06f47667fcb9f592fbb7c6ea7581ff23f773edd9af335e330ffd26b86a4cdc00' 'GB'
else
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=GB
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="Experiential"
	psk=06f47667fcb9f592fbb7c6ea7581ff23f773edd9af335e330ffd26b86a4cdc00
}

WPAEOF
   chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
   rfkill unblock wifi
   for filename in /var/lib/systemd/rfkill/*:wlan ; do
       echo 0 > $filename
   done
fi
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_keymap 'gb'
   /usr/lib/raspberrypi-sys-mods/imager_custom set_timezone 'Europe/Zurich'
else
   rm -f /etc/localtime
   echo "Europe/Zurich" >/etc/timezone
   dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="gb"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
   dpkg-reconfigure -f noninteractive keyboard-configuration
fi
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0
