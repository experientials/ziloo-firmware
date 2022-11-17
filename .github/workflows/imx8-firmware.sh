DOCKER_IMAGE_TAG="ziloo/image-builder-user:test"

# docker container run -d image-builder-user \
docker container run -it --rm \
    --platform linux/amd64 \
    --volume `pwd`/etc:/workspace/etc \
    --volume `pwd`/dist:/workspace/dist \
    --volume `pwd`/device/imx8:/workspace/device/imx8 \
    --volume `pwd`/mcuxsdk:/workspace/mcuxsdk \
    --volume `pwd`/downloads:/workspace/downloads \
    --volume `pwd`/cache:/workspace/cache \
    --volume `pwd`/sources:/workspace/sources \
    --volume `pwd`/sstate-cache:/workspace/sstate-cache \
    --entrypoint /bin/bash \
    "${DOCKER_IMAGE_TAG}" \

    # source ./etc/bitbake-with-setup -k ${IMAGES} -b build-${MACHINE}

# To experiment with this you can rebuild image locally with
# docker buildx build --platform linux/amd64 -t ziloo/image-builder-user:test .

