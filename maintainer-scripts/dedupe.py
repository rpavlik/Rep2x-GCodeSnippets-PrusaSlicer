#!/usr/bin/env python3

from configparser import ConfigParser

SECTION_PATH = 'Slic3r-configBundles/sections/'


def get_section(config):
    return config[list(config.keys())[1]]


def process_config(fn1, fn2):
    config = [ConfigParser(interpolation=None), ConfigParser(interpolation=None)]
    config[0].read(SECTION_PATH + fn1)
    config[1].read(SECTION_PATH + fn2)

    sections = [get_section(c) for c in config]
    keys = list(sections[1].keys())
    changed = False
    for key in keys:
        if key in sections[0] and key in sections[1] and sections[0].get(key) == sections[1].get(key):
            changed = True
            del sections[1][key]

    if changed:
        print("Removing config values from {} that match its parent {}".format(fn2, fn1))
        with open(SECTION_PATH + fn2, 'w', encoding='utf-8') as fp:
            config[1].write(fp)


#fn = 'printer_Rep2x_dual_material_LR.ini'
if __name__ == "__main__":
    import sys
    process_config(sys.argv[1], sys.argv[2])
