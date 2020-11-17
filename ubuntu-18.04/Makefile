all: build

build:
	docker build -t coldnew/yocto-build:ubuntu-18.04 .
rebuild:
	docker build --no-cache -t coldnew/yocto-build:ubuntu-18.04 .

run:
	docker run -it coldnew/yocto-build:ubuntu-18.04

deploy:
	docker push coldnew/yocto-build:ubuntu-18.04
