#!/usr/bin/env python3

from configparser import ConfigParser

SECTION_PATH = 'Slic3r-configBundles/sections/'
GCODE_PATH = 'Slic3r-GCode/'

FILE_DATA = {
    'printer_Rep2x_dual_material_LR.ini': {
        'end_gcode': 'End.gcode',
        'start_gcode': 'Start-dual-extruders.gcode',
        'toolchange_gcode': 'ToolChange.gcode',
    },
    'printer_Rep2x_single_material_L.ini': {
        'end_gcode': 'End.gcode',
        'start_gcode': 'Start-left-extruder.gcode',
    },
    'printer_Rep2x_single_material_R.ini': {
        'end_gcode': 'End.gcode',
        'start_gcode': 'Start-right-extruder.gcode',
    },
}

def get_gcode_as_string(fn):
    lines = []
    with open(fn, 'r', encoding='utf-8') as fp:
        for line in fp:
            lines.append(line.strip())
    return '\\n'.join(lines)

def process_config(config_fn):

    config = ConfigParser()
    config.read(SECTION_PATH + config_fn)
    print(list(config.keys()))
    section = list(config.keys())[1]

    data = FILE_DATA[config_fn]

    for key, gcode in data.items():
        config[section][key] = get_gcode_as_string(GCODE_PATH + gcode)

    with open(SECTION_PATH + config_fn, 'w', encoding='utf-8') as fp:
        config.write(fp)

#fn = 'printer_Rep2x_dual_material_LR.ini'
if __name__ == "__main__":
    import sys
    process_config(sys.argv[1])
