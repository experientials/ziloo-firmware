# Continuous Integration

GitHub Actions are used to build the firmware images which then produces artifacts.

The actions are triggered when a Hardware branch(`hw/*`) receives a push.
The actions are defined to trigger for the specific branch producing artifacts for the specific platform.

Multiple runners are deployed to facilitate the different needs.
Modify `runs-on` for the different actions depending on what you aim to do

- `bigbuild` `Linode` is a 300GB build node hosted on Linode
- `raspbian` is for Raspberry Pi directed testing of hardware
- `macOS` `arm64` is for experimentation with Mac builds and App integration.

To run from a developer machine refer to the specific hardware branch for the specific scripts.


### Building Docker container locally

You can build a docker image locally by,

> docker buildx build --platform linux/amd64 -f Dockerfile -t ziloo/image-builder --target ziloo-builder .   

To push result image into registry use --push or to load image into docker use --load 


### Setup Raspberry Pi Actions runner

Install runner using instructions under GitHub/ ziloo-firmware/Actions/Runners/Setup

In the Terminal process add additional label `raspbian`.

To make the runner start automatically you can either set it up to silently run and log to /tmp or as an LXDE Terminal window

Edit the headless boot script

> sudo nano /etc/rc.local

Add at the top

```shell
exec 1> /tmp/actions-runner.log 2>&1
set -x

/home/pi/actions-runner/run.sh
```

Or open the autostart file for LXDE on the Pi

```
sudo nano /etc/xdg/lxsession/LXDE-pi/autostart
```

Edit the autostart file and append a new @lxterminal command

```
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@lxterminal -e bash /home/pi/actions-runner/run.sh
```
