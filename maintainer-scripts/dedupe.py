#!/usr/bin/env python3

from configparser import ConfigParser
import argparse


from common import (conditionally_prepend_section_path, get_section, get_section_name, merge_config,
                    intersect_config_sections, read_config, write_config, create_config)

SECTION_PATH = 'Slic3r-configBundles/sections/'


def find_and_load_config(fn):
    fn = conditionally_prepend_section_path(fn)
    config = read_config(fn)
    return fn, config


def process_config(base_config, derived_fn):

    derived_fn, derived_config = find_and_load_config(derived_fn)

    base_section = get_section(base_config)
    derived_section = get_section(derived_config)

    changed = False

    inherits = derived_section.get("inherits")
    _, base_section_name = get_section_name(base_config).split(":")
    if not base_section_name == inherits:
        if inherits:
            print("Something wrong with inherits= in", derived_fn)
            print("Got '{}' but expected '{}'".format(
                inherits, base_section_name))
            return

        derived_section['inherits'] = base_section_name
        changed = True

    keys = list(derived_section.keys())
    for key in keys:
        if key in base_section and key in derived_section and base_section.get(key) == derived_section.get(key):
            changed = True
            del derived_section[key]

    if changed:
        print("Removing config values from {} that match its parent(s)".format(
            derived_fn))
        write_config(derived_config, derived_fn)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="De-duplicate inheriting PrusaSlicer config sections")
    parser.add_argument('--base', metavar='SECTION', nargs='+', required=True,
                        help=f'a base config.ini section filename (#{SECTION_PATH} prepended automatically)')
    parser.add_argument('--derived', metavar='SECTION', nargs='+',
                        help=f'a derived config.ini section filename (#{SECTION_PATH} prepended automatically)')

    args = parser.parse_args()

    if len(args.base) > 1:
        early_base_fns = args.base[:-1]
        last_base_fn = args.base[-1]
        _, last_base_config = find_and_load_config(last_base_fn)
        last_base_section = get_section(last_base_config)

        # Process bases in reverse order so we don't wipe out an override
        for base_fn in reversed(early_base_fns):
            _, current_base_config = find_and_load_config(base_fn)
            merge_config(get_section(current_base_config), last_base_section)

        for derived_fn in args.derived:
            process_config(last_base_config, derived_fn)
    else:
        base_fn = args.base[0]
        _, base_config = find_and_load_config(base_fn)
        for derived_fn in args.derived:
            process_config(base_config, derived_fn)
