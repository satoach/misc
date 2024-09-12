ifndef INCLUDED_MYCMN_MK
INCLUDED_MYCMN_MK := 1

SHELL := /bin/bash
print_val = @echo $(1) is $($(1))
nproc := $(shell nproc)

help:  ## Print help
	@echo "USAGE (makefile for using my vim's quickfix):"
	@grep -h -E '^[a-zA-Z_%-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	sort -u | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

endif # INCLUDED_MYCMN_MK
