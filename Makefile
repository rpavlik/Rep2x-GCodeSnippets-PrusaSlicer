bundle := Slic3r-configBundles/Slic3r_config_bundle.ini
custom_bundle := Slic3r-configBundles/custom.ini

SECTION_DIR := Slic3r-configBundles/sections
PLACEHOLDER_SCRIPT := /You-need-to-update-print-configs/specify-path-to/make_fcp_x3g
QUIET ?= @

# If found, include config.mk for local settings
-include config.mk

bases := \
	print__rpavlik_base.ini \
	print__rpavlik_PETG-base.ini \
	print__rpavlik_PLA-base.ini \
	printer__Rep2x_base.ini \

printers := \
	printer_Rep2x_dual_material_LR.ini \
	printer_Rep2x_single_material_L.ini \
	printer_Rep2x_single_material_R.ini

pla_settings := \
	print_rpavlik_PLA-medium.ini \
	print_rpavlik_PLA-rough.ini \

petg_settings := \
	print_rpavlik_PETG-medium.ini \
	print_rpavlik_PETG-rough.ini \
	print_rpavlik_PETG-rough_0.24_wip_1108.ini \

filaments := \
	filament_PETG-AMZ-Basics-BLK.ini \
	filament_PLA-PRO-eSun-COOLWHITE.ini \
	filament_PLA-PRO-eSun-GLOW.ini \

# presets.ini comes last, by convention.
# Not sure if it's required.
sections := \
	$(SECTION_DIR)/lead.ini \
	$(addprefix $(SECTION_DIR)/,$(bases)) \
	$(addprefix $(SECTION_DIR)/,$(petg_settings)) \
	$(addprefix $(SECTION_DIR)/,$(pla_settings)) \
	$(addprefix $(SECTION_DIR)/,$(filaments)) \
	$(addprefix $(SECTION_DIR)/,$(printers)) \
	$(SECTION_DIR)/presets.ini

GCODE_SCRIPT := maintainer-scripts/inject-gcode.py

DEDUPE := python3 maintainer-scripts/dedupe.py

PRINTER_FILES := $(addprefix $(SECTION_DIR)/,$(printers))

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

	@echo "De-duplicating config settings from parent settings."

	$(QUIET)$(DEDUPE) \
		--base print__rpavlik_base.ini \
		--derived print__rpavlik_PETG-base.ini print__rpavlik_PLA-base.ini

	$(QUIET)$(DEDUPE) \
		--base print__rpavlik_base.ini print__rpavlik_PETG-base.ini \
		--derived $(petg_settings)

	$(QUIET)$(DEDUPE) \
		--base print__rpavlik_base.ini print__rpavlik_PLA-base.ini \
		--derived $(pla_settings)

	$(QUIET)$(DEDUPE) --base printer__Rep2x_base.ini --derived $(printers)

help:
	@echo "Targets:"
	@echo "all: Build the bundle $(bundle), and custom bundle $(custom_bundle) if SCRIPT_PATH supplied"
	@echo "clean: Remove the bundle $(bundle) and custom bundle $(custom_bundle)"
	@echo "fixup: Clean up sections: Remove personal data (postprocess script path, octoprint host and key), deduplicate, etc."
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

$(PRINTER_FILES) : $(SECTION_DIR)/printer_%.ini : $(GCODE_SCRIPT) $(GCODES)
	@echo "Injecting GCode snippets into: $@"
	$(QUIET)python3 $(GCODE_SCRIPT) $(@F)
