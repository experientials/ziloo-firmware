# Setting up Development environment

Fork the main branch if you are making general improvements.
And make a PR to merge them on to the main branch as well as the relevant hardware(`hw/*`) branches.

Fork a hardware(`hw/*`) branch, if you work on a firmware release for a specific platform.
If possible you should fork the main branch for work on firmware work and later cherry pick the merge onto
the relevant hardware branches.
Hardware branches have to be kept compatible with main branch, but can diverge from it.
Hardware branches currently do not allow force push to ensure no history is lost.
In future setups there may be release branches that hold the qualified hardware branches which
have passed tests and been rebased on main at the time, thereby capturing the long term history.

- [Setup for Rockchip Programming](./docs/rockchip/README.md)
- [Setup for i.MX8 Programming](./docs/imx8/README.md)


## Add plugins to VSCode

* Docker
* Python
* CMake & CMake Tools
* Docker Explorer
* Cortex-Debug
* Remote - Containers
* Jupyter
* Better TOML


## SD Card Format

For development and debugging use an SD Card or USB stick. It must be partitioned,

- With MBR FAT32 (diskutil eraseDisk FAT32 ALPINE MBR $(DISK))
- 1Gb FAT32 boot partition
- 3.4Gb extFS 4 rootfs partition

An empty SD Card image is generated with `make ziloo-raw-image`, which will generate `ziloo-dev-card.img.zip`.


## Docker

The build and testing is run primarily in Docker. The firmware can be tested with QEMU in a dedicated docker container. 
Building the firmware also takes place in a Docker container. 
Where possible all firmware will be built with the same docker container `ziloo/image-builder`.

When working with Docker you disk can fill up quickly. It is a good idea to run `docker system prune` once finished on adjusting
the build.
