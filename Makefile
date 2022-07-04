SHELL:=/bin/bash

.DEFAULT_GOAL := all

.PHONY: build sent_env clean

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=


COORDINATE_CONVERSION_PROJECT="coordinate_conversion"
COORDINATE_CONVERSION_VERSION="latest"
COORDINATE_CONVERSION_TAG="${COORDINATE_CONVERSION_PROJECT}:${COORDINATE_CONVERSION_VERSION}"

set_env: 
	$(eval PROJECT := ${COORDINATE_CONVERSION_PROJECT}) 
	$(eval TAG := ${COORDINATE_CONVERSION_TAG})


all: build

build: set_env
	rm -rf ${ROOT_DIR}/coordinate_conversion/build
	docker build --network host \
                 --tag $(shell echo ${TAG} | tr A-Z a-z) \
                 --build-arg PROJECT=${PROJECT} .
	mkdir -p "${ROOT_DIR}/tmp/${PROJECT}/build"
	docker cp $$(docker create --rm $(shell echo ${TAG} | tr A-Z a-z)):/tmp/${PROJECT}/build tmp/${PROJECT}/build
	cp -r "${ROOT_DIR}/tmp/${PROJECT}/build/build" "${ROOT_DIR}/${PROJECT}"
	rm -rf ${ROOT_DIR}/tmp

clean: set_env
	rm -rf "${ROOT_DIR}/coordinate_conversion/build"
	rm -rf "${ROOT_DIR}/tmp"
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${PROJECT}) 2> /dev/null || true

build_docker_layers: 
	@DOCKER_BUILDKIT=0 make build #| grep "\-\-\->" | \
#                                       grep -v "Using" | \
#                                       sed "s| \-\-\-> ||g" | \
#                                       sed "s|Running in ||g" | \
#                                       tr '\n' ' ' >> .docker_layers_cache
#	@echo "($$(git rev-parse --abbrev-ref HEAD):$$(git rev-parse --short HEAD))" >> .docker_layers_cache
