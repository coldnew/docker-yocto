all: build

build:
	docker build -t coldnew/yocto-build .

run:
	docker run -it coldnew/yocto-build

deploy:
	docker push coldnew/yocto-build
