bundle := Slic3r-configBundles/Slic3r_config_bundle.ini

SECTION_DIR := Slic3r-configBundles/sections

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
INJECT_GCODE_CMD = python3 $(GCODE_SCRIPT) $1

all: $(bundle)
clean:
	-rm -f $(bundle)

# Combine all the sections
$(bundle): $(sections) Makefile
	cat $(sections) > $@

GCODES := $(wildcard Slic3r-GCode/*.gcode)

$(printers) : $(SECTION_DIR)/printer_%.ini : $(GCODE_SCRIPT) $(GCODES)
	$(call INJECT_GCODE_CMD,$(@F))
