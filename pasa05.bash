#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    pasa05.bash                                             #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Fifth step of the pasa pipeline. Join all chromossomes  #
#             in a unique file, correcting the beggining of their     #
#             ids accordingly to pasa.data.                           #
# date:       09/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ###########################################################
DATE=2013_07_08
ORGANISM=Sb

## SCRIPT #############################################################
# Store beginnig of the process
date > pasa05.date

perl join_chrs.pl pasa < pasa.data

# Store end of the process
date >> pasa05.date
