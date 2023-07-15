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
export WC_TOOL="wc"
export HEAD_TOOL="head"
export SED_TOOL="sed"
export AWK_TOOL="awk"
export PSP_TOOL="ps -q"
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL="gdate"
	WC_TOOL="gwc"
	HEAD_TOOL="ghead"
	SED_TOOL="gsed"
	AWK_TOOL="gawk"
	PSP_TOOL="ps -p"
	if [ ! $(command -v ${DATE_TOOL}) ]
	then
		echo "Error - Cannot find GNU coreutils tools (e.g., ${DATE_TOOL}, " \
			 "${WC_TOOL}, ${HEAD_TOOL}, ${PSP_TOOL}."
		echo "Install those with \`brew install coreutils\`"
		return -1
	fi
	if [ ! $(command -v ${SED_TOOL}) ]
	then
		echo "Error - Cannot find ${SED_TOOL}. Install it with \`brew install gnu-sed\`"
		return -1
	fi
	if [ ! $(command -v ${AWK_TOOL}) ]
	then
		echo "Error - Cannot find ${AWK_TOOL}. Install it with \`brew install gawk\`"
		return 1
    fi
fi

