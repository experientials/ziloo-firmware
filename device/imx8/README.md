# i.MX8 Plus firmware

The github actions will build the firmware based on pushes to `hw/imx8`.

* Attempt to build the iMX firmware. If successful artifacts will be uploaded.
* If successful(with artifacts an) the commit has tag starting with `r` create a release with the artifacts and the release_name using the tag

https://trstringer.com/github-actions-create-release-upload-artifacts/

Although somewhat outdated the `hw/rockchip` branch can be used for inspiration.
