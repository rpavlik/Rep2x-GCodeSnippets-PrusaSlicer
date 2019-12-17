#!/bin/sh
make -C $(dirname $0) \
    SCRIPT_PATH=/home/user/bin/make_fcp_x3g \
    OCTOPRINT_HOST=http://octopi.local/ \
    OCTOPRINT_KEY=YOUR_API_KEY_HERE \
    "$@"
