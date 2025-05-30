ifndef INCLUDED_MYUTIL_MK
INCLUDED_MYUTIL_MK := 1

SHELL := /bin/bash

nproc := $(shell nproc)
print_val = @echo $(1) is $($(1))

# 色定義（NO_COLOR が設定されていれば空文字になる）
ifeq ($(NO_COLOR),)
COLOR_CYAN := \033[36m
COLOR_RESET := \033[0m
else
COLOR_CYAN :=
COLOR_RESET :=
endif

help:  ## Print help
	@echo "USAGE (makefile for using my vim's quickfix):"
	@grep -h -E '^[a-zA-Z_%-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	sort -u | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\t$(COLOR_CYAN)%-20s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ""

.PHONY: help
endif # INCLUDED_MYUTIL_MK
