default: build-builder build-firmware

docker-push: push-firmware push-builder

build-builder:
	docker build -t ziloo/image-builder -f ./device/builder.Dockerfile --target ziloo-builder .

build-firmware:
	docker build -t ziloo/firmware -f ./device/firmware.Dockerfile --target develop .
	docker build -t ziloo/firmware-x11 -f ./device/firmware.Dockerfile --target develop-x11 .

push-builder: build-builder
	docker login --username ziloo
	docker push ziloo/image-builder

push-firmware: build-firmware
	docker login --username ziloo
	docker push ziloo/firmware

ziloo-raw-image: 
	docker run --rm --privileged -v $(shell pwd):/workspace ziloo/image-builder /device/raw/raw-sd-card.sh

shell: build-builder
	docker run --rm -ti --privileged -v $(shell pwd):/workspace ziloo/image-builder bash

testshell: build-builder
	docker run --rm -ti --privileged -v $(shell pwd)/device:/device -v $(shell pwd):/workspace ziloo/image-builder bash

extract-disk-image: build-builder
	docker run --rm --privileged -v $(shell pwd):/workspace ziloo/image-builder /device/extract-card.sh /workspace/${IMG_PATH}
	# kpartx -l /workspace/images/maixpy3-v831-800m-64m-512m-sp2305_240240_20210802_dd.img  

tag:
	git tag ${TAG}
	git push origin ${TAG}

ziloo-runtime: build-firmware
	docker run --rm -ti --privileged ziloo/runtime /bin/sh

ziloo-runtime-vnc: build-firmware
	docker run -d --privileged -p 5900:5900 ziloo/runtime-x11

ziloo-runtime-rdp: build-firmware
	docker run -d --name rdp --shm-size 1g -p 3389:3389 ziloo/runtime