#!/usr/bin/env python3

from configparser import ConfigParser

SECTION_PATH = 'Slic3r-configBundles/sections/'


def get_section_name(config):
    return list(config.keys())[1]


def get_section(config):
    return config[get_section_name(config)]


def process_config(base_fn, derived_fn):
    base_config = ConfigParser(interpolation=None)
    base_config.read(SECTION_PATH + base_fn)

    derived_config = ConfigParser(interpolation=None)
    derived_config.read(SECTION_PATH + derived_fn)

    base_section = get_section(base_config)
    derived_section = get_section(derived_config)

    inherits = derived_section.get("inherits")
    if not inherits or not get_section_name(base_config).endswith(inherits):
        print("Something wrong with inherits= in", derived_fn)
        return

    keys = list(derived_section.keys())
    changed = False
    for key in keys:
        if key in base_section and key in derived_section and base_section.get(key) == derived_section.get(key):
            changed = True
            del derived_section[key]

    if changed:
        print("Removing config values from {} that match its parent {}".format(
            derived_fn, base_fn))
        with open(SECTION_PATH + derived_fn, 'w', encoding='utf-8') as fp:
            derived_config.write(fp)


#fn = 'printer_Rep2x_dual_material_LR.ini'
if __name__ == "__main__":
    import sys
    base = sys.argv[1]
    deriveds = sys.argv[2:]
    for derived in deriveds:
        process_config(base, derived)
