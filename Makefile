bundle := Slic3r-configBundles/Slic3r_config_bundle.ini
custom_bundle := Slic3r-configBundles/custom.ini

SECTION_DIR := Slic3r-configBundles/sections
QUIET ?= @

printers := \
	$(SECTION_DIR)/printer_Rep2x_dual_material_LR.ini \
	$(SECTION_DIR)/printer_Rep2x_single_material_L.ini \
	$(SECTION_DIR)/printer_Rep2x_single_material_R.ini

# presets.ini comes last, by convention.
# Not sure if it's required.
sections := \
	$(SECTION_DIR)/lead.ini \
	$(SECTION_DIR)/print_rpavlik_PETG-rough.ini \
	$(SECTION_DIR)/filament_PETG-AMZ-Basics-BLK.ini \
	$(printers) \
	$(SECTION_DIR)/presets.ini

GCODE_SCRIPT := maintainer-scripts/inject-gcode.py

all: $(bundle)
clean:
	-rm -f $(bundle) $(custom_bundle)
.PHONY: all clean

# Combine all the sections
$(bundle): $(sections) Makefile
	@echo "Generating bundle: $@"
	$(QUIET)cat $(sections) > $@


ifneq (,$(strip $(SCRIPT_PATH)))
# Do a replacement of the post-processor path if SCRIPT_PATH is defined to something useful
customized: $(bundle) Makefile
	@echo "Generating bundle with customized post-process path: $(custom_bundle)"
	$(QUIET)cat $< | sed 's:/You-need-to-update-print-configs/specify-path-to/make_fcp_x3g:$(strip $(SCRIPT_PATH)):' > $(custom_bundle)
all: customized
.PHONY: customized
endif


# Inject GCode into config sections
GCODES := $(wildcard Slic3r-GCode/*.gcode)

$(printers) : $(SECTION_DIR)/printer_%.ini : $(GCODE_SCRIPT) $(GCODES)
	@echo "Injecting GCode snippets into: $@"
	$(QUIET)python3 $(GCODE_SCRIPT) $(@F)
