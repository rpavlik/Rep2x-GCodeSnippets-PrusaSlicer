
#QUIET ?= @
QUIET :=
SCRIPT_DIR := ../../maintainer-scripts



include ../../files.mk
# Command defs for cross-platform compat.
include ../../commands.mk

INTERSECT := $(PYTHON) $(SCRIPT_DIR)/intersect.py
DEDUPE := $(PYTHON) $(SCRIPT_DIR)/dedupe.py
SPLIT := $(PYTHON) $(SCRIPT_DIR)/split.py

all: $(petg_settings) $(pla_settings)
.PHONY: all

clean:
	-$(RM) split_stamp
.PHONY: clean

UPDATED_BASES :=  print__rpavlik_PLA-base.ini print__rpavlik_PETG-base.ini
SUPERBASE := print__rpavlik_base.ini
split_stamp $(SUPERBASE) $(UPDATED_BASES): PrusaSlicer_config_bundle.ini
	$(QUIET)$(SPLIT) $<
	$(QUIET)$(INTERSECT) --out "print:*rpavlik PETG-base" $(petg_settings)
	$(QUIET)$(INTERSECT) --out "print:*rpavlik PLA-base" $(pla_settings)
	$(QUIET)$(INTERSECT) --out "print:*rpavlik base" $(UPDATED_BASES)
	$(QUIET)$(DEDUPE) --base $(SUPERBASE) --derived $(UPDATED_BASES)
	$(QUIET)$(TOUCH) $@

# print__rpavlik_PETG-base.ini: split_stamp

# print__rpavlik_PLA-base.ini: split_stamp

# print__rpavlik_base.ini: print__rpavlik_PLA-base.ini print__rpavlik_PETG-base.ini

$(petg_settings): split_stamp
	$(QUIET)$(DEDUPE) --base print__rpavlik_base.ini print__rpavlik_PETG-base.ini  --derived $@

just-split: PrusaSlicer_config_bundle.ini
	$(QUIET)$(SPLIT) $<
.PHONY: just-split
