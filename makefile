.PHONY: all check-tools version build update-files git-ops pr clean

# Helper to source .env and get variables
GET_VAR = ./scripts/get_env_var.sh

# Define variables by sourcing .env
BASE_NAME := $(shell $(GET_VAR) BASE_NAME)
VERSION := $(shell cat .version)
BUILD_DIR := $(shell $(GET_VAR) BUILD_DIR)
UPDATE_JSON_FILE := $(shell $(GET_VAR) UPDATE_JSON_FILE)
UPDATE_RDF_FILE := $(shell $(GET_VAR) UPDATE_RDF_FILE)
XPI_FILE := $(BUILD_DIR)/$(BASE_NAME)-$(VERSION).xpi

# Define dependencies
all: pr

pr: update-files
	./scripts/manage_pr.sh

update-files: $(XPI_FILE)
	./scripts/update_files.sh
	cp $(UPDATE_JSON_FILE) $(UPDATE_RDF_FILE)

build: $(XPI_FILE)

$(XPI_FILE): .version
	./scripts/build.sh $(BASE_NAME) $(VERSION)

.version: check-tools
	./scripts/manage_version.sh
	touch .version

check-tools:
	./scripts/check_tools.sh

clean:
	rm -f .version $(BUILD_DIR)/*.xpi $(UPDATE_RDF_FILE) $(UPDATE_JSON_FILE)
