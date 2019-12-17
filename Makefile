bundle := Slic3r-configBundles/Slic3r_config_bundle.ini
custom_bundle := Slic3r-configBundles/custom.ini

SECTION_DIR := Slic3r-configBundles/sections
PLACEHOLDER_SCRIPT := /You-need-to-update-print-configs/specify-path-to/make_fcp_x3g
QUIET ?= @

# If found, include config.mk for local settings
-include config.mk

printers := \
	$(SECTION_DIR)/printer__Rep2x_base.ini \
	$(SECTION_DIR)/printer_Rep2x_dual_material_LR.ini \
	$(SECTION_DIR)/printer_Rep2x_single_material_L.ini \
	$(SECTION_DIR)/printer_Rep2x_single_material_R.ini

# presets.ini comes last, by convention.
# Not sure if it's required.
sections := \
	$(SECTION_DIR)/lead.ini \
	$(SECTION_DIR)/print_rpavlik_PETG-medium.ini \
	$(SECTION_DIR)/print_rpavlik_PETG-rough.ini \
	$(SECTION_DIR)/print_rpavlik_PETG-rough_0.24_wip_1108.ini \
	$(SECTION_DIR)/print_rpavlik_PLA-medium.ini \
	$(SECTION_DIR)/print_rpavlik_PLA-rough.ini \
	$(SECTION_DIR)/filament_PETG-AMZ-Basics-BLK.ini \
	$(SECTION_DIR)/filament_PLA-PRO-eSun-COOLWHITE.ini \
	$(SECTION_DIR)/filament_PLA-PRO-eSun-GLOW.ini \
	$(printers) \
	$(SECTION_DIR)/presets.ini

GCODE_SCRIPT := maintainer-scripts/inject-gcode.py

all: $(bundle)
clean:
	-rm -f $(bundle) $(custom_bundle)
fixup:
	@echo "Stripping personal data from sections."
	$(QUIET) sed -i \
		-e 's:post_process =.*:post_process = $(PLACEHOLDER_SCRIPT):' \
		-e 's:print_host =.*:print_host = :' \
		-e 's:printhost_apikey =.*:printhost_apikey = :' \
		$(sections)

help:
	@echo "Targets:"
	@echo "all: Build the bundle $(bundle), and custom bundle $(custom_bundle) if SCRIPT_PATH supplied"
	@echo "clean: Remove the bundle $(bundle) and custom bundle $(custom_bundle)"
	@echo "fixup: Remove personal data (postprocess script path, octoprint host and key) from section files"
	@echo "Note:"
	@echo "If you define SCRIPT_PATH, you'll get a customized bundle containing your script path,"
	@echo "as well as your OCTOPRINT_HOST and OCTOPRINT_KEY if specified."
	@echo "You can do this on the command line, or (preferably) in a config.mk file."
	@echo "Pass QUIET= on the command line to show all commands being executed."

.PHONY: all clean fixup help

# Combine all the sections
$(bundle): $(sections) Makefile
	@echo "Generating bundle: $@"
	$(QUIET)cat $(sections) > $@


ifneq (,$(strip $(SCRIPT_PATH)))
# Do a replacement of the post-processor path if SCRIPT_PATH is defined to something useful
customized: $(bundle) Makefile
	@echo "Generating bundle with customized post-process path, etc: $(custom_bundle)"
	$(QUIET)cat $< | \
		sed \
		-e 's:$(PLACEHOLDER_SCRIPT):$(strip $(SCRIPT_PATH)):' \
		-e 's%print_host =.*%print_host = $(strip $(OCTOPRINT_HOST))%' \
		-e 's:printhost_apikey =.*:printhost_apikey = $(strip $(OCTOPRINT_KEY)):' \
		> $(custom_bundle)
all: customized
.PHONY: customized
endif


# Inject GCode into config sections
GCODES := $(wildcard Slic3r-GCode/*.gcode)

$(printers) : $(SECTION_DIR)/printer_%.ini : $(GCODE_SCRIPT) $(GCODES)
	@echo "Injecting GCode snippets into: $@"
	$(QUIET)python3 $(GCODE_SCRIPT) $(@F)
