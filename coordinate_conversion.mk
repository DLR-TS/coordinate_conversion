# This Makefile contains useful recipes that can be included in downstream projects.


ifndef coordinate_conversion_MAKEFILE_PATH

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
coordinate_conversion_project:=coordinate_conversion
COORDINATE_CONVERSION_PROJECT:=${coordinate_conversion_project}

coordinate_conversion_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
make_gadgets_PATH:=${coordinate_conversion_MAKEFILE_PATH}/make_gadgets
REPO_DIRECTORY:=${coordinate_conversion_MAKEFILE_PATH}

coordinate_conversion_tag:=$(shell cd "${make_gadgets_PATH}" && make get_sanitized_branch_name REPO_DIRECTORY="${REPO_DIRECTORY}")
COORDINATE_CONVERSION_TAG:=${coordinate_conversion_tag}

coordinate_conversion_image:=${coordinate_conversion_project}:${coordinate_conversion_tag}
COORDINATE_CONVERSION_IMAGE:=${coordinate_conversion_image}

coordinate_conversion_CMAKE_BUILD_PATH:="${coordinate_conversion_project}/build"
COORDINATE_CONVERSION_CMAKE_BUILD_PATH:=${coordinate_conversion_CMAKE_BUILD_PATH}

coordinate_conversion_CMAKE_INSTALL_PATH:="${coordinate_conversion_CMAKE_BUILD_PATH}/install"
COORDINATE_CONVERSION_CMAKE_INSTALL_PATH:=${coordinate_conversion_CMAKE_INSTALL_PATH}

.PHONY: build_coordinate_conversion 
build_coordinate_conversion: ## Build coordinate_conversion
	cd "${coordinate_conversion_MAKEFILE_PATH}" && make

.PHONY: clean_coordinate_conversion
clean_coordinate_conversion: ## Clean coordinate_conversion build artifacts
	cd "${coordinate_conversion_MAKEFILE_PATH}" && make clean

.PHONY: branch_coordinate_conversion
branch_coordinate_conversion: ## Returns the current docker safe/sanitized branch for coordinate_conversion
	@printf "%s\n" ${coordinate_conversion_tag}

.PHONY: image_coordinate_conversion
image_coordinate_conversion: ## Returns the current docker image name for coordinate_conversion
	@printf "%s\n" ${coordinate_conversion_image}

.PHONY: update_coordinate_conversion
update_coordinate_conversion:
	cd "${coordinate_conversion_MAKEFILE_PATH}" && git pull

endif
