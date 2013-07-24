#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

## VARIABLES ##########################################################
N_CHR=10
ORGANISM=Sb
DATE=2013_07_08
FILE_NAME=${ORGANISM}_${DATE}_pasa

SCRIPT_PATH=/home/renatocf/scripts
GFF3=${FILE_NAME}.gff3
GTF=${FILE_NAME}.gtf

## SCRIPT #############################################################
# Store beginnig of the process
date > pasa04.date

# Log message
echolog "Converting..." 

# Converts from gff3 to gtf
for i in $(seq -f %02.0f 10); 
do
    # Log message
    echolog "Processing chr${i}"
    
    cd CHR_${i} # Gets in directory with chromossomes
    date > pasa04_chr${i}.date
    
    FILE_NAME=${ORGANISM}_${DATE}_chr${i}_pasa
    GFF3=${FILE_NAME}.gff3
    GTF=${FILE_NAME}.gtf
    
    $(${SCRIPT_PATH}/gff3_to_gtf_pasa.pl < ${GFF3} > ${GTF} 2> pasa04.err)
    RES=$?
    
    date >> pasa04_chr${i}.date
    cd .. # Leaves directory with chromossomes
    
    # Error message
    if [ "$RES" -ne "0" ]; 
        then echoerr "Problems while converting chr${i}"
    fi
done

# Store end of the process
date >> pasa04.date
