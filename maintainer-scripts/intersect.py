#!/usr/bin/env python3

import argparse

from common import (conditionally_prepend_section_path, get_section,
                    intersect_config_sections, read_config, write_config, create_config)


def read_config_and_get_section(section_fn):
    current_config = read_config(
        conditionally_prepend_section_path(section_fn))
    return get_section(current_config)


if __name__ == "__main__":
    from pprint import pprint
    parser = argparse.ArgumentParser(
        description="De-duplicate inheriting PrusaSlicer config sections")
    parser.add_argument('--out', metavar='SECTION', type=str, required=True,
                        help=f'an output section name (converted to a filename automatically)')
    parser.add_argument('sections', metavar='SECTION', nargs='+',
                        help=f'section filenames (section path prepended automatically if required)')

    args = parser.parse_args()

    out_section = read_config_and_get_section(args.sections[0])
    # pprint(dict(out_section.items()))

    for section_fn in args.sections[1:]:
        out_section = intersect_config_sections(
            out_section, read_config_and_get_section(section_fn))
        # pprint(out_section)

    out_config = create_config()
    out_config[args.out] = out_section
    pprint(out_config)


    write_config(out_config)
