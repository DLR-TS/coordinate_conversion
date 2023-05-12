SHELL:=/bin/bash

.DEFAULT_GOAL := all

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

include coordinate_conversion.mk 

MAKEFLAGS += --no-print-directory


.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

SUBMODULES_PATH?=${ROOT_DIR}

include ${SUBMODULES_PATH}/ci_teststand/ci_teststand.mk

.PHONY: all
all: build

.PHONY: build
build: clean root_check docker_group_check _build _docker_save ## Build coordinate_conversion

.PHONY: set_env
set_env: 
	$(eval PROJECT := ${COORDINATE_CONVERSION_PROJECT}) 
	$(eval TAG := ${COORDINATE_CONVERSION_TAG})

.PHONY: _build
_build: set_env 
	docker build --network host \
                 --tag ${PROJECT}:${TAG} \
                 --build-arg PROJECT=${PROJECT} .
	docker cp $$(docker create --rm ${PROJECT}:${TAG}):/tmp/${PROJECT}/${PROJECT}/build "${ROOT_DIR}/${PROJECT}"

.PHONY: _docker_save
_docker_save: set_env
	@docker save --output "${ROOT_DIR}/${PROJECT}/build/${PROJECT}_${TAG}.tar" ${PROJECT}:${TAG} 

.PHONY: _docker_load
_docker_load: set_env
	@docker load --input "${ROOT_DIR}/${PROJECT}/build/${PROJECT}_${TAG}.tar" > /dev/null 2>&1 || true

.PHONY: clean
clean: set_env ## Clean coordinate_conversion build artifacts
	rm -rf "${ROOT_DIR}/${PROJECT}/build"
	docker rm $$(docker ps -a -q --filter "ancestor=${PROJECT}:${TAG}") --force 2> /dev/null || true
	docker rmi $$(docker images -q ${PROJECT}:${TAG}) --force 2> /dev/null || true

.PHONY: test
test: ci_test
