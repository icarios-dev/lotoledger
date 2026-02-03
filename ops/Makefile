MANIFEST ?= data/datasets_manifest.tsv
TMP_DIR ?= ../tmp/data
ZIP_DIR ?= $(TMP_DIR)/zips
OUT_DIR ?= $(TMP_DIR)/extracted
META_DIR ?= $(TMP_DIR)/meta

.PHONY: help data clean dist-clean

help:
	@printf "%s\n" \
	  "Targets:" \
	  "  data       Download/extract datasets into tmp/data" \
	  "  clean       Remove extracted data (keeps zips)" \
	  "  dist-clean  Remove downloaded zips (forces re-download)"

data:
	MANIFEST="$(MANIFEST)" ZIP_DIR="$(ZIP_DIR)" OUT_DIR="$(OUT_DIR)" META_DIR="$(META_DIR)" \
	  ./data/fetch_datasets.sh

clean:
	rm -rf "$(OUT_DIR)" "$(META_DIR)"

dist-clean:
	rm -rf "$(ZIP_DIR)"
