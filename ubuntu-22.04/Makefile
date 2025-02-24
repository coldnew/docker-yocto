all: build

build:
	docker build -t coldnew/yocto-build:ubuntu-22.04 .

run:
	docker run -it coldnew/yocto-build:ubuntu-22.04

deploy:
	docker push coldnew/yocto-build:ubuntu-22.04
