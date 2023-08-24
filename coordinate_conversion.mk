# This Makefile contains useful recipes that can be included in downstream projects.

ifeq ($(filter coordinate_conversion.mk, $(notdir $(MAKEFILE_LIST))), coordinate_conversion.mk)

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
COORDINATE_CONVERSION_PROJECT=coordinate_conversion

COORDINATE_CONVERSION_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
ifeq ($(SUBMODULES_PATH),)
    COORDINATE_CONVERSION_SUBMODULES_PATH:=${COORDINATE_CONVERSION_MAKEFILE_PATH}
else
    COORDINATE_CONVERSION_SUBMODULES_PATH:=$(shell realpath ${SUBMODULES_PATH})
endif
MAKE_GADGETS_PATH:=${COORDINATE_CONVERSION_SUBMODULES_PATH}/make_gadgets
ifeq ($(wildcard $(MAKE_GADGETS_PATH)/*),)
    $(info INFO: To clone submodules use: 'git submodule update --init --recursive')
    $(info INFO: To specify alternative path for submodules use: SUBMODULES_PATH="<path to submodules>" make build')
    $(info INFO: Default submodule path is: ${COORDINATE_CONVERSION_MAKEFILE_PATH}')
    $(error "ERROR: ${MAKE_GADGETS_PATH} does not exist. Did you clone the submodules?")
endif
REPO_DIRECTORY:=${COORDINATE_CONVERSION_MAKEFILE_PATH}

COORDINATE_CONVERSION_TAG:=$(shell cd ${MAKE_GADGETS_PATH} && make get_sanitized_branch_name REPO_DIRECTORY=${REPO_DIRECTORY})

COORDINATE_CONVERSION_IMAGE=${COORDINATE_CONVERSION_PROJECT}:${COORDINATE_CONVERSION_TAG}

COORDINATE_CONVERSION_CMAKE_BUILD_PATH="${COORDINATE_CONVERSION_PROJECT}/build"
COORDINATE_CONVERSION_CMAKE_INSTALL_PATH="${COORDINATE_CONVERSION_CMAKE_BUILD_PATH}/install"

include ${MAKE_GADGETS_PATH}/make_gadgets.mk
include ${MAKE_GADGETS_PATH}/docker/docker-tools.mk


.PHONY: build_coordinate_conversion 
build_coordinate_conversion: ## Build coordinate_conversion
	cd "${COORDINATE_CONVERSION_MAKEFILE_PATH}" && make

.PHONY: clean_coordinate_conversion
clean_coordinate_conversion: ## Clean coordinate_conversion build artifacts
	cd "${COORDINATE_CONVERSION_MAKEFILE_PATH}" && make clean

.PHONY: branch_coordinate_conversion
branch_coordinate_conversion: ## Returns the current docker safe/sanitized branch for coordinate_conversion
	@printf "%s\n" ${COORDINATE_CONVERSION_TAG}

.PHONY: image_coordinate_conversion
image_coordinate_conversion: ## Returns the current docker image name for coordinate_conversion
	@printf "%s\n" ${COORDINATE_CONVERSION_IMAGE}

.PHONY: update_coordinate_conversion
update_coordinate_conversion:
	cd "${coordinate_conversion_MAKEFILE_PATH}" && git pull

endif
