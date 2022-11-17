# ziloo-builder-eu-central

This is an x86 Ubuntu 20.04LTS server hosted on Linode. It has 16GB RAM and 320GB SSD.

* IP 172.105.246.8 2a01:7e01::f03c:92ff:fec3:48bb

It should build the Ziloo Firmware images that you already have defined. But instead of manually, it should happen automatically with Continuous Integration via GitHub Actions.

All you have to do is
1) Install the GitHub Actions Runner package on this new server(LINODE.md)
2) Install docker
3) Configure build action for 4 docker build targets
4) Configure pulling/pushing from GitHub with SSH
5) Generate build artefacts to be accessed in Action results

Resulting build should end up on a branch prefixed with `hw/`

* `hw/imx8`
* `hw/rp2`
* `hw/nrf`

P.S. Please don't commit directly to branches main/builder. If need be create new branches to play with. We then merge your branch when all is working


## Connecting via SSH

Regular SSH
> ssh root@172.105.246.8

LISH access indirect
> ssh -t thepia@lish-frankfurt.linode.com ziloo-builder-eu-central

To gain access please provide me with a SSH public key that I can add.

To copy the build output
> scp root@172.105.246.8:~/imx-yocto-bsp/build/tmp/deploy/images/lec-imx8mp/imx-image-full-lec-imx8mp.tar.bz2 .


## Setup Linode with correct keys

Use `ssh-copy-id`. [How to use SCP (secure copy) with ssh key authentication](https://www.techrepublic.com/article/how-to-use-secure-copy-with-ssh-key-authentication/)

> scp -i ~/.ssh/id_rsa.pub root@172.105.74.116:~/imx-yocto-bsp/build/tmp/deploy/images/lec-imx8mp/*.bz2 .

Artifacts

- imx-image-full-lec-imx8mp-*.rootfs.tar.bz2
- imx-image-full-lec-imx8mp-*.rootfs.wic.bz2
- imx-image-full-lec-imx8mp.tar.bz2
- imx-image-full-lec-imx8mp.wic.bz2


## Docker Support

The server must [support docker](https://bobcares.com/blog/linode-install-docker/) to run our builds.
Linode has added [support for Docker on Linode](https://www.linode.com/blog/containerization/docker-on-linode/).
You might need to change docker to [run without sudo](https://stackoverflow.com/questions/56784492/docker-compose-permissionerror-errno-13-permission-denied-manage-py) by changing `/etc/systemd/system/sockets.target.wants/docker.socket`.

The builds will also be Linux, but use docker to enable dedicated configurations and installation cached in the form of docker images and containers.


## GitHub Actions

An GitHub action must be triggered when the `[builder`](https://github.com/experientials/ziloo-firmware/tree/builder) branch is updated to build new firmware.

Initial clone can be done with

> git clone git@github.com:experientials/ziloo-firmware.git --recursive --branch builder

The builder server is registed with Github as an Actions Runner for the repository.
Need to add it as a [self-hosted runner](https://github.com/experientials/ziloo-firmware/settings/actions/runners). If you don't have access to Maintain the repository ask to be added to the "Build Supervisor" team.

I think it makes sense to keep the Git repository between builds. A working cache for Buildroot/Yocto can also be mapped so the `repo` commands can reuse past downloads.


## Builder script

It should run docker compose builds to create the firmware images.

* If it fails the logs are copied to /dist
* If it succeeds the images are copied to /dist
* After success the dist images are commited with "Firmware builder images" message and merged+pushed into the main branch.

In dist the target device has a dedicated directory. Hence `/dist/rv1109` and `/dist/rv1126` will hold the output.

Output logs and images must be linked in GitHub actions as build artifacts. Success/Fail status must be correct.

Large outputs must be compressed to be sure that the size is well below 50MB.

Steps in script(as it seems to me):

1) Git pull recursive and with force checkout(junk previous working directory)
2) Check out the builder branch
3) Use docker to run the builds
4) Do the builds for RV1109/RV1126 and both apps (Facial Gate will eventually be disabled)
5) Upon completion flag the build as completed/failed 


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
$ ./run.sh
```

Using your self-hosted runner

```
# Use this YAML in your workflow file for each job
runs-on: self-hosted
```

For additional details about configuring, running, or shutting down the runner, please check out our product docs.
