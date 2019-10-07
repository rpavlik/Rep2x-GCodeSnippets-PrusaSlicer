#!/usr/bin/env python3

import fileinput
import re

fp = None
section = None
for line in fileinput.FileInput():
    if line.startswith('['):
        if fp:
            fp.close()
            fp = None
        section = line.strip()[1:-1]
        print(section)
        fp = open(section.replace(":", "_").replace(" ", "_") + '.ini', 'w', encoding='utf-8')
    if fp:
        fp.write(line)


if fp:
    fp.close()
    fp = None
