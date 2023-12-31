DATE=$(shell date +%F)
USER=slechev
IMAGE=openwebrxplus-bg

all:
	docker buildx create --name owrxp-builder --driver docker-container --bootstrap --use --driver-opt network=host || true
	docker buildx build --push --pull --platform=linux/amd64,linux/arm64,linux/arm/v7 -t $(USER)/$(IMAGE):$(DATE) -t $(USER)/$(IMAGE) .
	docker buildx rm --keep-state owrxp-builder

build:
	docker build --pull -t $(USER)/$(IMAGE):$(DATE) -t $(USER)/$(IMAGE) .

run:
	@mkdir -p ./owrx/etc ./owrx/var
	@docker run --rm -h $(IMAGE) --name $(IMAGE) --device /dev/bus/usb -p 8073:8073 -v ./owrx/var:/var/lib/openwebrx -v ./owrx/etc:/etc/openwebrx $(USER)/$(IMAGE)

admin:
	@docker exec -it $(USER)/$(IMAGE) /usr/bin/openwebrx admin adduser af

push:
	@docker push $(USER)/$(IMAGE):$(DATE)
	@docker push $(USER)/$(IMAGE)

dev:
	@S6_CMD_ARG0=/bin/bash docker run -it --rm -p 8073:8073 --device /dev/bus/usb --name owrxp-build --entrypoint /bin/bash $(USER)/$(IMAGE)
