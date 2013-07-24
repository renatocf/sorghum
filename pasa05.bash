#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

## VARIABLES ##########################################################
DATE=2013_07_08
ORGANISM=Sb

## SCRIPT #############################################################
# Store beginnig of the process
date > pasa05.date

perl join_chrs.pl pasa < pasa.data

# Store end of the process
date >> pasa05.date
