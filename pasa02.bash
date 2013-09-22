#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    pasa02.bash                                             #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Second step of pasa pipeline. Runs pasa over all        #
#             chromossomes inside their own directories, based on     #
#             the ESTs generated in step 1.                           #
# date:       08/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ###########################################################
# Pasa
PASAHOME=/usr/local/genome/pasa

# ESTs
PATH_EST=/home3/renatocf/sorghum/sorghum_data/Sorghum_bicolor.EST
FILE_EST=Sorghum_bicolor.EST.fa
FILE_ESTCLEAN=Sorghum_bicolor.EST.fa.clean

## SCRIPT #############################################################
# Store beginnig of the process
date > pasa02.date

# Run PASA for every chromossome
for i in $(seq -f %02.0f 10); 
do
    # Log message
    echolog "Processing chr${i}"
    
    cd CHR_${i} # Gets into the chromossomes dir.
    date > pasa02_chr${i}.date
    
    # Runs PASA for chrxx
    $(${PASAHOME}/scripts/Launch_PASA_pipeline.pl \
        -c alignAssembly.config -C -R \
        -g CHR_${i}_RefSeq.fasta \
        -t ${PATH_EST}/${FILE_ESTCLEAN} -T \
        -u ${PATH_EST}/${FILE_EST} \
        1> pasa02_chr${i}.log \
        2> pasa02_chr${i}.err \ 
    )
    RES=$?
    
    date >> pasa02_chr${i}.date
    cd .. # Leaves the chromossomes dir.
    
    # Mensagem de erro
    if [ "$RES" -ne "0" ]; 
        then echoerr "Problems while processing chr${i}"
    fi
done

# Store end of the process
date >> pasa02.date
