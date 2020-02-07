all: build

build:
	docker build -t coldnew/yocto-build:ubuntu-16.04 .

run:
	docker run -it coldnew/yocto-build:ubuntu-16.04

deploy:
	docker push coldnew/yocto-build:ubuntu-16.04
