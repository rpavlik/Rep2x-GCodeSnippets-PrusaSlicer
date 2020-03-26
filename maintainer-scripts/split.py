#!/usr/bin/env python3

import fileinput
import re
from common import section_to_filename

fp = None
section = None
for line in fileinput.FileInput():
    if line.startswith('['):
        if fp:
            fp.close()
            fp = None
        section = line.strip()[1:-1]
        print(section)
        fp = open(section_to_filename(section), 'w', encoding='utf-8')
    if fp:
        fp.write(line)


if fp:
    fp.close()
    fp = None
