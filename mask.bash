#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

PATH_RM=~renatocf/Software/RepeatMasker
SPECIES=Sorghum bicolor

date > mask.date 
for i in $(seq -f %02.0f ${n_chr}); 
do
    # Log message to indicate in which 
    # chr the program is in some moment
    echolog "Processing CHR_${i}"
    
    FILE=CHR_${i}_RefSeq.fasta
    CLEAN=${FILE}.clean
    MAP=${FILE}.map
    
    # Change dir to a specific chromossome one 
    cd CHR_${i}
    
    # Runs RepeatMasker to clean the genome
    $(${PATH_RM}/RepeatMasker \
        -species "${SPECIES}" \
        -nolow -parallel 2 \
        -engine wublast -x \
        -a ${FILE} \
        1> repeatmasker.log \
        2> repeatmasker.err)
    RES=$?
    
    if [ "$RES" -ne "0" ]; 
        then echoerr "Problems while processing chr${i} (RepeatMasker)"
    fi
    
    # Create the .map file with the masked regions
    $(perl create_map.pl < ${CLEAN} > ${MAP})
    RES=$?
    
    if [ "$RES" -ne "0" ]; 
        then echoerr "Problems while processing chr${i} (create_map.pl)"
    fi
    
    # Go back to the main dir
    cd ..
done
date >> mask.date &
