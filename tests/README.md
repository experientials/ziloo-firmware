

https://medium.com/swlh/setting-up-a-conda-environment-in-less-than-5-minutes-e64d8fc338e4


For Mac OS M1 use [Miniforge](https://github.com/conda-forge/miniforge)


Running tests requires an installed miniconda environment or similar

> conda create -n firmware python=3.7
> conda activate firmware
> conda install tensorflow opencv
> conda env export > firmware.yml
> conda info --envs


> conda deactivate


Test calibration with Open CV

> opencv_version
> opencv_interactive-calibration


Should show checkerboard image:

> python ./opencv_test/calibrate.py

## i.MX8 Debian

user: root
password: zilootest


## Raspberry Pi demo environment

Branch `hw/builder`.

Use "Raspberry Pi Imager" Advanced options

- hostname `ziloo-test.local`
- SSH with public-key auth only
- username: pi
- password: zilootest
- locale: Zurich/gb

Write card

Boot partition (capacity 268.4 MB) will contain

- firstrun.sh
- config.txt
- cmdline.txt

To be used for updates to Bob and Ziloo enough space
must be present to hold

- Base images for Raspberry Pi 55 MB
- recent stream history
- u-boot patches
- Yocto Kernel Image 31 MB
- tee.bin 2 MB
- Overlays 1+ MB

Expand the boot partition keeping it Fat32 from 256MB up to 1024MB.
Reserve the second half of the SD Card for UBIFS or F2FS
Expand the rootfs (extFS4) to fill up the rest of the first half

Open raspi-config to enable Serial Port, 1-Wire, I2C.

> sudo apt install gparted etckeeper minicom code

Expand rootfs using gparted

> sudo gparted

Upload the SSH key with GitHub account. Generate a unique key, or get it from equal SD Card.

> ssh-keygen -t ed25519 -C "ziloo@thepia.com"

```bash
sudo git config --global user.email "henrik@thepia.com"
sudo git config --global user.name "Henrik Vendelbo"
```

Set up [`etckeeper`](http://etckeeper.branchable.com/README/) to share `/etc`.

```
sudo etckeeper init /etc
sudo git branch -m hw/builder
sudo git remote add origin git@github.com:experientials/ziloo-firmware.git
sudo git push --set-upstream origin hw/builder
cd /etc
sudo git status
```

Setup the `usr` domain with all relevant software. In the future this would be linked to a separate partition
with Git repository and working directory.

```
cd /usr
sudo git init .
sudo git branch -m builder/etc
sudo git remote add origin git@github.com:experientials/ziloo-firmware.git
sudo git add .
sudo git config --global user.email "henrik@thepia.com"
sudo git config --global user.name "Henrik Vendelbo"
sudo git commit -m "usr base files" 
sudo git push --set-upstream origin builder/etc
```


### Serial port comms

> minicom -b 115200 -o -D /dev/serial1

> minicom -b 115200 -o -D /dev/serial0

The console on i.MX8 UART2 can be reached on ttyAMA0

> minicom -b 115200 -D /dev/ttyAMA0

The low power Cortex M7 console UART4 should be on ttyAMA2

> minicom -b 115200 -D /dev/ttyAMA2