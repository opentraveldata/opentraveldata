#!/bin/bash
#

##
# GNU tools
#
# On MacOS:
#  - Reference: https://ryanparman.com/posts/2019/using-gnu-command-line-tools-in-macos-instead-of-freebsd-tools/
#  - coreutils provides, in a non exhaustive list, date, wc
#  - sed is provided by gnu-sed
#
export DATE_TOOL="date"
export SED_TOOL="sed"
export WC_TOOL="wc"
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL="gdate"
	SED_TOOL="gsed"
	WC_TOOL="gwc"
	if [ ! $(command -v ${DATE_TOOL}) ]
	then
		echo "Error - Cannot find GNU coreutils tools (e.g., ${DATE_TOOL}, " \
			 "${WC_TOOL}. Install those with \`brew install coreutils\`"
		return -1
	fi
	if [ ! $(command -v ${SED_TOOL}) ]
	then
		echo "Error - Cannot find ${SED_TOOL}. Install it with \`brew install gnu-sed\`"
		return -1
	fi
fi
