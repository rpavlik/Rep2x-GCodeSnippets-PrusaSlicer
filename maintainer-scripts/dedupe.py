#!/usr/bin/env python3

from configparser import ConfigParser
import argparse

SECTION_PATH = 'Slic3r-configBundles/sections/'


def get_section_name(config):
    return list(config.keys())[1]


def get_section(config):
    return config[get_section_name(config)]


def process_config(base_fn, derived_fn, skip_inherit_check=False):
    base_config = ConfigParser(interpolation=None)
    base_config.read(SECTION_PATH + base_fn)

    derived_config = ConfigParser(interpolation=None)
    derived_config.read(SECTION_PATH + derived_fn)

    base_section = get_section(base_config)
    derived_section = get_section(derived_config)

    if not skip_inherit_check:
        inherits = derived_section.get("inherits")
        kind, base_section_name = get_section_name(base_config).split(":")
        if not inherits or not base_section_name == inherits:
            print("Something wrong with inherits= in", derived_fn)
            print("Got '{}' but expected '{}'".format(
                inherits, base_section_name))
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


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="De-duplicate inheriting PrusaSlicer config sections")
    parser.add_argument('--base', metavar='SECTION', nargs='+', required=True,
                        help=f'a base config.ini section filename (#{SECTION_PATH} prepended automatically)')
    parser.add_argument('--derived', metavar='SECTION', nargs='+',
                        help=f'a derived config.ini section filename (#{SECTION_PATH} prepended automatically)')

    args = parser.parse_args()
    import sys

    if len(args.base) > 1:
        early_bases = args.base[:-1]
        last_base = args.base[-1]
        for derived in args.derived:
            # Process bases in reverse order so we don't wipe out an override
            process_config(last_base, derived)
            for base in reversed(early_bases):
                process_config(base, derived, skip_inherit_check=True)
    else:
        base = args.base[0]
        for derived in args.derived:
            process_config(base, derived)
