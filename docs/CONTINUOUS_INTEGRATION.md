# Continuous Integration

GitHub Actions are used to build the firmware images which then produces artifacts.

The actions are triggered when a Hardware branch(`hw/*`) receives a push.
The actions are defined to trigger for the specific branch producing artifacts for the specific platform.

Multiple runners are deployed to facilitate the different needs.
Modify `runs-on` for the different actions depending on what you aim to do

- `big-build` `Linode` is a 300GB build node hosted on Linode
- `big-build` `Friedheim` is a 400GB build node privately hosted
- `raspbian` is for Raspberry Pi directed testing of hardware
- `macOS` `arm64` is for experimentation with Mac builds and App integration.

To run from a developer machine refer to the specific hardware branch for the specific scripts.

### Notes on repo, west & yocto

- [In yocto (poky) why is the layers config in the build/ folder?](https://stackoverflow.com/questions/45864903/in-yocto-poky-why-is-the-layers-config-in-the-build-folder)


### Direct ssh like github runners docker

Starting docker container

```sh
su github-runner-user
cd ~/actions-runner/_work/ziloo-firmware/ziloo-firmware/
docker-compose up -d
docker ps
```

```sh
docker exec --user build ziloo-builder-user sh -c 'echo do it!'
```


### Future docker tuning

- [Docker images and files chown](https://blog.mornati.net/docker-images-and-files-chown)


### Setup big-build

    sudo apt install docker docker-compose
    sudo snap remove git-remove
    sudo curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
    sudo chmod a+x /usr/local/bin/repo


Download

```
# Create a folder
$ mkdir actions-runner && cd actions-runner
# Download the latest runner package
$ curl -o actions-runner-linux-x64-2.283.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.283.1/actions-runner-linux-x64-2.283.1.tar.gz
# Optional: Validate the hash
$ echo "aebaaf7c00f467584b921f432f9f9fb50abf06e1b6b226545fbcbdaa65ed3031  actions-runner-linux-x64-2.283.1.tar.gz" | shasum -a 256 -c
# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.283.1.tar.gz
```

Configure

```
# Create the runner and start the configuration experience
$ ./config.sh --url https://github.com/experientials/ziloo-firmware --token AAARXPURQOP2UPGXPACBBYLBM47XC
# Last step, run it!
$ sudo ./svc.sh install
$ sudo ./svc.sh start
```

Using your self-hosted runner

```
# Use this YAML in your workflow file for each job
runs-on: self-hosted
```

For additional details about configuring, running, or shutting down the runner, please check out our product docs.




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


#### Notes: Build output

~/imx-yocto-bsp/build/tmp/deploy/images/lec-imx8mp

scp root@172.105.74.116/root/imx-yocto-bsp/build/tmp/deploy/images/lec-imx8mp/


```sh
root@localhost:~/imx-yocto-bsp/build/tmp/deploy/images/lec-imx8mp# ls
Image
Image--5.4-r0-lec-imx8mp-20220709083139.bin
Image-lec-imx8mp.bin
imx-boot
imx-boot-lec-imx8mp-sd.bin-flash_evk
imx-boot-tools
imx-image-full-imx-imx-boot-bootpart.wks
imx-image-full-lec-imx8mp-20220709124403.rootfs.manifest
imx-image-full-lec-imx8mp-20220709124403.testdata.json
imx-image-full-lec-imx8mp-20220710023103.rootfs.tar.bz2
imx-image-full-lec-imx8mp-20220710023103.rootfs.wic.bmap
imx-image-full-lec-imx8mp-20220710023103.rootfs.wic.bz2
imx-image-full-lec-imx8mp.manifest
imx-image-full-lec-imx8mp.tar.bz2
imx-image-full-lec-imx8mp.testdata.json
imx-image-full-lec-imx8mp.wic.bmap
imx-image-full-lec-imx8mp.wic.bz2
imx-image-full.env
imx8mp_m7_TCM_hello_world.bin
imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.bin
imx8mp_m7_TCM_rpmsg_lite_str_echo_rtos.bin
imx8mp_m7_TCM_sai_low_power_audio.bin
lec-imx8mp--5.4-r0-lec-imx8mp-20220709083139.dtb
lec-imx8mp-auoB101UAN01-mipi-panel--5.4-r0-lec-imx8mp-20220709083139.dtb
lec-imx8mp-auoB101UAN01-mipi-panel-lec-imx8mp.dtb
lec-imx8mp-auoB101UAN01-mipi-panel.dtb
lec-imx8mp-hydis-hv150ux2--5.4-r0-lec-imx8mp-20220709083139.dtb
lec-imx8mp-hydis-hv150ux2-lec-imx8mp.dtb
lec-imx8mp-hydis-hv150ux2.dtb
lec-imx8mp-lec-imx8mp.dtb
lec-imx8mp-wifi--5.4-r0-lec-imx8mp-20220709083139.dtb
lec-imx8mp-wifi-lec-imx8mp.dtb
lec-imx8mp-wifi.dtb
lec-imx8mp.dtb
lpddr4_pmu_train_1d_dmem_202006.bin
lpddr4_pmu_train_1d_imem_202006.bin
lpddr4_pmu_train_2d_dmem_202006.bin
lpddr4_pmu_train_2d_imem_202006.bin
modules--5.4-r0-lec-imx8mp-20220709083139.tgz
modules-lec-imx8mp.tgz
signed_dp_imx8m.bin
signed_hdmi_imx8m.bin
tee.bin
tee.mx8mpevk.bin
u-boot-lec-imx8mp.bin
u-boot-lec-imx8mp.bin-sd
u-boot-sd-2020.04-r0.bin
u-boot-spl.bin
u-boot-spl.bin-lec-imx8mp
u-boot-spl.bin-lec-imx8mp-2020.04-r0-sd-2020.04-r0
u-boot-spl.bin-lec-imx8mp-sd
u-boot-spl.bin-sd
u-boot.bin
u-boot.bin-sd
```
