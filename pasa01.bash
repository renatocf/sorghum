#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    pasa01.bash                                             #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      First step of pasa pipeline. Runs seqclean over a       #
#             specific .fasta file with ESTs. This script makes some  #
#             files which can improve the other steps.                #
# date:       08/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ###########################################################
PATH_EST=/home3/renatocf/sorghum/sorghum_data/Sorghum_bicolor.EST
FILE_EST=Sorghum_bicolor.EST.fa

## SCRIPT #############################################################
# Store beginnig of the process
date > pasa01.date

# Log message
echolog "Rodando seqclean"

# Cleans EST files
seqclean ${PATH_EST}/${FILE_EST} \
    > pasa01_seqclean.log 2> pasa01_seqclean.err 
RES=$?

# Error message
if [ "$RES" -ne "0" ]; 
    then echoerr "Problems while cleaning ESTs"
fi

# Store end of the process
date >> pasa01.date
