

### Enable VNC

1. `sudo raspi-config`, enable SSH & VNC Servcer, Set screen resolution (DMT Mode 82)
2. `sudo hostnamectl set-hostname ziloo-rpi`
1. Set `/etc/hostname` and `/etc/hosts`.
1. Run `source extra-packages.sh`


Connect to the dev machine over VNC at `ziloo-rpi.local`.





# Raspberry Pi Testing


## Hardware Setup

> sudo apt-get install vlc
> raspivid -o - -t 9999999 | cvlc -vvv stream:///dev/stdin --sout '#rtp{sdp=rtsp://:8554/}' :demux=h264


raspivid is used to capture the video

"-o -" causes the output to be written to stdout

"-t 0" sets the timeout to disabled

"-n" stops the video being previewed (remove if you want to see the video on the HDMI output)

cvlc is the console vlc player

"-vvv" and its argument specifies where to get the stream from

"-sout" and its argument specifies where to output it to 

