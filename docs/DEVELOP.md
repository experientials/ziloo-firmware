# Setting up Development environment

Fork the main branch if you are making general improvements.
And make a PR to merge them on to the main branch as well as the relevant hardware(`hw/*`) branches.
3rd party Hardware documentation and internal development information is kept on hardware specific branches.
The main branch should contain the firmware build scripts and documentation for using the firmware.

Fork a hardware(`hw/*`) branch, if you work on a firmware release for a specific platform.
If possible you should fork the main branch for work on firmware work and later cherry pick the 
merge onto the relevant hardware branches.
Hardware branches have to be kept compatible(rebased) with main branch, but can diverge from it.
Hardware branches currently do not allow force push to ensure no history is lost.
In future setups there may be release branches that hold the qualified hardware branches which
have passed tests and been rebased on main at the time, thereby capturing the long term history.

- [Setup for i.MX8 Programming](./imx8/README.md)
- [i.MX8 Development](./imx8/DEVELOP.md)

## Required Software for Local Development

VS Code extensions

* Docker
* Python
* CMake & CMake Tools
* Docker Explorer
* Cortex-Debug
* Remote - Containers
* Jupyter
* Better TOML

The default setup on the native dev machine assumes

- Python 3.9 (Comes with miniforge)
- Miniforge3 `brew install miniforge`
- [Android Repo tool](https://android.googlesource.com/tools/repo) `snap install repo-tool` / `apt install repo` / `brew install repo`
- Zephyr Project - west (`pip3 install west`)

This allows compatibility with ML toolchains.

## macOS fixup

> brew install qemu libvirt terraform picocom
> brew upgrade git cmake go terraform qemu repo picocom ninja 


## Building Full Firmware

Build cache can be 200GB, so cleaning it may be required with [a script](https://stackoverflow.com/questions/45341760/how-should-the-sstate-cache-directory-be-deleted-in-yocto)

    ./scripts/sstate-cache-management.sh --remove-duplicated -d --cache-dir=<path to sstate-cached>

Use repo tool to set up the source code to be cloned with Git. This can be synced multiple times

    repo init -u https://github.com/experientials/ziloo-firmware -b imx-linux-honister -m imx-5.15.5-1.0.0_experientials.xml
    mkdir -p downloads
    mkdir -p cache
    mkdir -p sstate-cache
    mkdir -p sources

The `repo sync` will link scripts and pull git repositories to `sources`.
This can initially be done outside the docker container.

    repo sync

To make this usable the files must be accessable by the build user, and symlinks must be replicated.
If repo is called within docker, it also needs git user configs. A script is made to take these steps.

    docker exec ziloo-builder-user source ./etc/inside-docker

From hereon the `build` user must be used. `setup-bitbake` will set up a build directory used by the `build` user within docker.
If you attach to the container, make sure to call `su build`.

    docker exec -e MACHINE=ucm-imx8-plus --user build ziloo-builder-user source setup-bitbake -b build-${MACHINE}

Now you can build the image:

    docker exec --user build ziloo-builder-user bitbake -k imx-image-multimedia

Or you can bitbake specific projects

If dependencies(sources upstream) change they can be updated within the docker container(user: build)
or outside.

    docker exec --user build ziloo-builder-user repo sync

If the bitbake server fails to start properly, remove the .lock and .sock files within the build directory.

    docker exec --user build ziloo-builder-user rm bitbake.lock bitbake.sock



### Building Docker container locally

You can build a docker image locally by,

> docker buildx build --platform linux/amd64 -f Dockerfile -t ziloo/image-builder --target ziloo-builder --tag ziloo/image-builder:latest --tag ziloo/image-builder .   
> docker buildx build --platform linux/amd64 -f Dockerfile -t ziloo/image-builder-user --target ziloo-builder-user --tag ziloo/image-builder-user:latest --tag ziloo/image-builder-user .   

To push result image into registry use --push or to load image into docker use --load 


## Raspberry Pi features

- [Etckeeper](http://etckeeper.branchable.com)
- [Wifi to ethernet routing](https://www.instructables.com/Share-WiFi-With-Ethernet-Port-on-a-Raspberry-Pi/) - [Script to run](https://github.com/arpitjindal97/raspbian-recipes/blob/master/wifi-to-eth-route.sh)

Manually setting up the route didn't seem to work. Resetting `/etc` with `sudo git reset NNN` worked wonders.
Perhaps the bridge option should be used.


### Build variations

Machine | Environment |
--- | --- |
`ucm-imx8m-mini` | `export MACHINE=ucm-imx8m-mini LREPO=compulab-bsp-setup-imx8mm.xml`
`iot-gate-imx8`  | `export MACHINE=iot-gate-imx8 LREPO=compulab-bsp-setup-iot.xml`
`ucm-imx8m-plus` | `export MACHINE=ucm-imx8m-plus LREPO=compulab-bsp-setup-imx8mp.xml`
`iot-gate-imx8plus` | `export MACHINE=iot-gate-imx8plus	 LREPO=compulab-bsp-setup-imx8mp.xml`


Distro | Setup command  | Build command |
--- | --- | --- |
fslc-xwayland | DISTRO=fslc-xwayland source compulab-setup-environment build-fslc-${MACHINE} | ```bitbake -k fsl-image-multimedia-full```
fslc-framebuffer | DISTRO=fslc-framebuffer source compulab-setup-environment build-fslc-${MACHINE} | ```bitbake -k fsl-image-network-full-cmdline```
fsl-imx-<backend> | DISTRO=fsl-imx-<backend> source setup-bitbake -b build-${MACHINE} |


For more see [meta-imx](https://github.com/nxp-imx/meta-imx)


DISTROs are new and the way to configure for any backends.  Use DISTRO= instead of the -e on the setup script.
The -e parameter gets converted to the appropriate distro configuration.

Note: 
DirectFB is no longer supported in i.MX graphic builds.
The X11 and Framebuffer distros are only supported for i.MX 6 and i.MX 7.  i.MX 8 should use xwayland only.
XWayland is the default distro for all i.MX families.

- fls-image-machine-test
- fsl-image-mfgtool-initramfs: Seems to support uuu instead of mfgtool
- imx-image-core: Minimal image
- imx-image-multimedia: This image contains all the packages except QT6/OpenCV/Machine Learning packages.
- imx-image-full: This is the big image which includes imx-image-multimedia + OpenCV + QT6 + Machine Learning packages.


## SD Card Format

For development and debugging use an SD Card or USB stick. It must be partitioned,

- With MBR FAT32 (diskutil eraseDisk FAT32 ALPINE MBR $(DISK))
- 1GB FAT32 boot partition
- 3.4Gb extFS 4 rootfs partition

An empty SD Card image is generated with `make ziloo-raw-image`, which will generate `ziloo-dev-card.img.zip`.

As u-boot is on the eMMC or Flash chip it should be possible to create a dual-booting RPi-Alpine/Raspbian/Yocto SD Card
that can be used everywhere. This will be explored more.


## Docker

The build and testing is run primarily in Docker. The firmware can be tested with QEMU in a dedicated docker container. 
Building the firmware also takes place in a Docker container. 
Where possible all firmware will be built with the same docker container `ziloo/image-builder`.

When working with Docker you disk can fill up quickly. It is a good idea to run `docker system prune` once finished on adjusting
the build.
