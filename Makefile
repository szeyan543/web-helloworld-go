# Extremely simple HTTP server that responds on port 8000 with a hello message.

DOCKER_HUB_ID ?= ibmosquito
SERVICE_NAME:="web-hello-go"
PATTERN_NAME:="pattern-web-helloworld-go"
SERVICE_VERSION:="1.0.0"
ARCH:="amd64"

CONTAINER_CREDS:=

default: build run

build:
	docker build -t $(DOCKER_HUB_ID ?= ibmosquito)/$(SERVICE_NAME):$(SERVICE_VERSION) .

dev: stop build
	docker run -it -v `pwd`:/outside \
        --name ${SERVICE_NAME} \
        -p 8000:8000 \
		$(DOCKER_HUB_ID ?= ibmosquito)/$(SERVICE_NAME):$(SERVICE_VERSION) /bin/bash

run: stop
	docker run -d \
        --name ${SERVICE_NAME} \
        --restart unless-stopped \
        -p 8000:8000 \
        $(DOCKER_HUB_ID ?= ibmosquito)/$(SERVICE_NAME):$(SERVICE_VERSION)

test:
	@curl -sS http://127.0.0.1:8000

push:
	docker push $(DOCKER_HUB_ID ?= ibmosquito)/$(SERVICE_NAME):$(SERVICE_VERSION) 

publish-service:
	@ARCH=$(ARCH) \
	SERVICE_NAME="$(SERVICE_NAME)" \
	SERVICE_VERSION="$(SERVICE_VERSION)"\
	SERVICE_CONTAINER="$(DOCKER_HUB_ID ?= ibmosquito)/$(SERVICE_NAME):$(SERVICE_VERSION)" \
	hzn exchange service publish -O $(CONTAINER_CREDS) -f service.json --pull-image

publish-pattern:
	@ARCH=$(ARCH) \
	SERVICE_NAME="$(SERVICE_NAME)" \
	SERVICE_VERSION="$(SERVICE_VERSION)"\
	PATTERN_NAME="$(PATTERN_NAME)" \
	hzn exchange pattern publish -f pattern.json
 
stop:
	@docker rm -f ${SERVICE_NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKER_HUB_ID ?= ibmosquito)/$(SERVICE_NAME):$(SERVICE_VERSION) >/dev/null 2>&1 || :

agent-run:
	hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

agent-stop:
	hzn unregister -f

.PHONY: 
	build dev run push publish-service publish-pattern test stop clean agent-run agent-stop
