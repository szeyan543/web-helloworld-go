# Extremely simple HTTP server that responds on port 8000 with a hello message in HTML format.

# DockerHub ID of the third party providing the image (usually yours if building and pushing)
DOCKER_HUB_ID ?= szeyan11

# The Open Horizon Exchange's organization ID namespace where you will be publishing files
HZN_ORG_ID ?= examples

export SERVICE_NAME ?= web-hello-go
PATTERN_NAME ?= pattern-web-helloworld-go
DEPLOYMENT_POLICY_NAME ?= deployment-policy-web-helloworld-go
NODE_POLICY_NAME ?= node-policy-web-helloworld-go
export SERVICE_VERSION ?= 1.0.0
export SERVICE_CONTAINER := $(DOCKER_HUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION)
ARCH ?= amd64

# Detect Operating System running Make
OS := $(shell uname -s)

CONTAINER_CREDS ?=

default: build run

build:
	docker build -t $(SERVICE_CONTAINER) .

dev: stop build
	docker run -it -v `pwd`:/outside \
      --name ${SERVICE_NAME} \
      -p 8000:8000 \
      $(SERVICE_CONTAINER) /bin/bash

run: stop
	docker run -d \
      --name ${SERVICE_NAME} \
      --restart unless-stopped \
      -p 8000:8000 \
      $(SERVICE_CONTAINER)

check:
	@echo "=================="
	@echo "SERVICE DEFINITION"
	@echo "=================="
	@cat service.definition.json | envsubst
	@echo ""

test:
	@curl -sS http://127.0.0.1:8000

push:
	docker push $(SERVICE_CONTAINER) 

publish: publish-service publish-service-policy publish-deployment-policy

remove: remove-deployment-policy remove-service-policy remove-service

publish-service:
	@echo "=================="
	@echo "PUBLISHING SERVICE"
	@echo "=================="
	@hzn exchange service publish -O $(CONTAINER_CREDS) --json-file=service.definition.json --pull-image
	@echo ""

remove-service:
	@echo "=================="
	@echo "REMOVING SERVICE"
	@echo "=================="
	@hzn exchange service remove -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-service-policy:
	@echo "========================="
	@echo "PUBLISHING SERVICE POLICY"
	@echo "========================="
	@hzn exchange service addpolicy -f service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

remove-service-policy:
	@echo "======================="
	@echo "REMOVING SERVICE POLICY"
	@echo "======================="
	@hzn exchange service removepolicy -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-pattern:
	@ARCH=$(ARCH) \
      SERVICE_NAME="$(SERVICE_NAME)" \
      SERVICE_VERSION="$(SERVICE_VERSION)"\
      PATTERN_NAME="$(PATTERN_NAME)" \
      hzn exchange pattern publish -f pattern.json
 
publish-deployment-policy:
	@echo "============================"
	@echo "PUBLISHING DEPLOYMENT POLICY"
	@echo "============================"
	@hzn exchange deployment addpolicy -f deployment.policy.json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""

remove-deployment-policy:
	@echo "=========================="
	@echo "REMOVING DEPLOYMENT POLICY"
	@echo "=========================="
	@hzn exchange deployment removepolicy -f $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""

stop:
	@docker rm -f ${SERVICE_NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(SERVICE_CONTAINER) >/dev/null 2>&1 || :

agent-run:
	@echo "================"
	@echo "REGISTERING NODE"
	@echo "================"
	@hzn register --policy=node.policy.json
	@watch hzn agreement list

agent-run-pattern:
	hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

agent-stop:
	hzn unregister -f

deploy-check:
	@hzn deploycheck all -t device -B deployment.policy.json --service=service.definition.json --service-pol=service.policy.json --node-pol=node.policy.json

log:
	@echo "========="
	@echo "EVENT LOG"
	@echo "========="
	@hzn eventlog list
	@echo ""
	@echo "==========="
	@echo "SERVICE LOG"
	@echo "==========="
	@hzn service log -f $(SERVICE_NAME)

.PHONY: 
	default build dev run test check push publish remove publish-service remove-service publish-service-policy remove-service-policy publish-pattern publish-deployment-policy remove-deployment-policy stop clean agent-run agent-run-pattern agent-stop deploy-check log
