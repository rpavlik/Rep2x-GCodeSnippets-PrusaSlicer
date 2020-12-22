bundle := Slic3r-configBundles/Slic3r_config_bundle.ini
custom_bundle := Slic3r-configBundles/custom.ini

SECTION_DIR := Slic3r-configBundles/sections
PLACEHOLDER_SCRIPT := /You-need-to-update-print-configs/specify-path-to/make_fcp_x3g
QUIET ?= @

# If found, include config.mk for local settings
-include config.mk

# Include file lists
include files.mk

# Command defs for cross-platform compat.
include commands.mk

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

DEDUPE := $(PYTHON) maintainer-scripts/dedupe.py

PRINTER_FILES := $(addprefix $(SECTION_DIR)/,$(printers))

all: $(bundle)
clean:
	-$(RM) $(bundle) $(custom_bundle)


fixup:
	@$(ECHO) "Stripping personal data from sections."
	$(QUIET) $(SED) -i \
		-e 's:post_process =.*:post_process = $(PLACEHOLDER_SCRIPT):' \
		-e 's:print_host =.*:print_host = :' \
		-e 's:printhost_apikey =.*:printhost_apikey = :' \
		$(sections)

	@$(ECHO) "De-duplicating config settings from parent settings."

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

fixup-wildcard: fixup
	$(QUIET)$(DEDUPE) \
		--base print__rpavlik_base.ini print__rpavlik_PLA-base.ini \
		--derived $(wildcard $(SECTION_DIR)/print_rpavlik_PLA*.ini)
	$(QUIET)$(DEDUPE) \
		--base print__rpavlik_base.ini print__rpavlik_PETG-base.ini \
		--derived $(wildcard $(SECTION_DIR)/print_rpavlik_PETG*.ini)

help:
	@$(ECHO) "Targets:"
	@$(ECHO) "all: Build the bundle $(bundle), and custom bundle $(custom_bundle) if SCRIPT_PATH supplied"
	@$(ECHO) "clean: Remove the bundle $(bundle) and custom bundle $(custom_bundle)"
	@$(ECHO) "fixup: Clean up sections: Remove personal data (postprocess script path, octoprint host and key), deduplicate, etc."
	@$(ECHO) "fixup-wildcard: fixup, plus fixup all sections with the right name, not just the ones listed in the makefile."
	@$(ECHO) "update: split without intersect, then fixup-wildcard"
	@$(ECHO) "split: Split $(SECTION_DIR)/PrusaSlicer_config_bundle.ini into sections."
	@$(ECHO) "Note:"
	@$(ECHO) "If you define SCRIPT_PATH, you'll get a customized bundle containing your script path,"
	@$(ECHO) "as well as your OCTOPRINT_HOST and OCTOPRINT_KEY if specified."
	@$(ECHO) "You can do this on the command line, or (preferably) in a config.mk file."
	@$(ECHO) "Pass QUIET= on the command line to show all commands being executed."

.PHONY: all clean fixup help split fixup-wildcard update

# Combine all the sections
$(bundle): $(sections) Makefile
	@$(ECHO) "Generating bundle: $@"
	$(QUIET)$(CAT) $(sections) > $@

split: $(SECTION_DIR)/PrusaSlicer_config_bundle.ini
	$(MAKE) -C $(SECTION_DIR)

update: $(SECTION_DIR)/PrusaSlicer_config_bundle.ini
	$(MAKE) -C $(SECTION_DIR) just-split
	$(MAKE) fixup-wildcard

ifneq (,$(strip $(SCRIPT_PATH)))
# Do a replacement of the post-processor path if SCRIPT_PATH is defined to something useful
customized: $(bundle) Makefile
	@$(ECHO) "Generating bundle with customized post-process path, etc: $(custom_bundle)"
	$(QUIET)$(CAT) $< | \
		$(SED) \
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
	@$(ECHO) "Injecting GCode snippets into: $@"
	$(QUIET)$(PYTHON) $(GCODE_SCRIPT) $(@F)
