SHELL:=/bin/bash

.DEFAULT_GOAL := all

.PHONY: build sent_env clean

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=


COORDINATE_CONVERSION_PROJECT="coordinate_conversion"
COORDINATE_CONVERSION_VERSION="latest"
COORDINATE_CONVERSION_TAG="${COORDINATE_CONVERSION_PROJECT}:${COORDINATE_CONVERSION_VERSION}"

.PHONY: sent_env
set_env: 
	$(eval PROJECT := ${COORDINATE_CONVERSION_PROJECT}) 
	$(eval TAG := ${COORDINATE_CONVERSION_TAG})


.PHONY: all
all: build

.PHONY: build
build: set_env clean
	rm -rf ${ROOT_DIR}/coordinate_conversion/build
	docker build --network host \
                 --tag $(shell echo ${TAG} | tr A-Z a-z) \
                 --build-arg PROJECT=${PROJECT} .
	docker cp $$(docker create --rm $(shell echo ${TAG} | tr A-Z a-z)):/tmp/${PROJECT}/build "${ROOT_DIR}/${PROJECT}"

.PHONY: clean
clean: set_env
	rm -rf "${ROOT_DIR}/coordinate_conversion/build"
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${PROJECT}) 2> /dev/null || true
