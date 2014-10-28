#!/bin/sh

#MIRROR_URL=rsync://wildwolf.fr/hostip
MIRROR_URL=rsync://hostip.info/hostip

rsync -avz --progress ${MIRROR_URL} ./

