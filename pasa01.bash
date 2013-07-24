#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

## VARIABLES ##########################################################
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
