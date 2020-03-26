#!/usr/bin/env python3 -i

from configparser import ConfigParser
from pathlib import Path

SECTION_PATH = 'Slic3r-configBundles/sections/'


def get_section_name(config):
    keys = list(config.keys())
    if len(keys) > 2:
        raise RuntimeError(
            "We have more than a default section and a single named section!")
    if len(keys) == 1:
        return keys[-1]
    return keys[1]


def get_section(config):
    return config[get_section_name(config)]


def merge_config(base, derived):
    for k, v in base.items():
        derived.setdefault(k, v)


def intersect_config_sections(a, b):
    result = {}
    for k, v in a.items():
        if b.get(k) == v:
            result[k] = v
    return result


def conditionally_prepend_section_path(fn):
    if Path(fn).exists():
        return fn
    return SECTION_PATH + fn


def create_config():
    return ConfigParser(interpolation=None)


def read_config(fn):
    config = ConfigParser(interpolation=None)
    config.read(fn)
    return config


def section_to_filename(section_name):
    return section_name.replace(":", "_").replace(" ", "_").replace("*", "_") + '.ini'


def write_config(config, fn=None):
    if not fn:
        fn = section_to_filename(get_section_name(config))

    print("Writing to", fn)
    with open(fn, 'w', encoding='utf-8') as fp:
        config.write(fp)
