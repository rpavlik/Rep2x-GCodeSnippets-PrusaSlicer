# Copyright 2020, Ryan Pavlik
# SPDX-License-Identifier: BSL-1.0

ifeq ($(shell uname),Windows_NT)
RM ?= busybox rm -f
SED ?= busybox sed
ECHO ?= busybox echo
CAT ?= busybox cat
TOUCH ?= busybox touch
else
RM ?= rm -f
SED ?= sed
ECHO ?= echo
CAT ?= cat
TOUCH ?= touch
endif
PYTHON ?= python3
