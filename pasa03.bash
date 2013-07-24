#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

## SCRIPT #############################################################
# Create pasa.gff3 for every chromossome
for i in $(seq -f %02.0f 10); 
do
    # Log message
    echo "Processing chr${i}"
    
    cd CHR_${i} # Gets in directory with chromossomes
    date > pasa03_chr${i}.date
    
    # Creates organism_date_pasa.gff3
    $(pasa_asmbl_genes_to_GFF3.dbi \
        -M ${ORGANISM}_${DATE}_${i}:localhost -p pasa:pasa \
        1> ${ORGANISM}_${DATE}_chr${i}_pasa.gff3 \
        2> pasa03_chr${i}.err \
    )
    RES=$? # Exit status
    
    date >> pasa03_chr${i}.date
    cd .. # Leaves directory with chromossomes
    
    # Error message
    if [ "$RES" -ne "0" ]; 
        then echoerr "Problems while processing chr${i}"
    fi
done
