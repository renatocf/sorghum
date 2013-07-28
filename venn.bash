#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

DATE=2013_07_26
VENN=nucleotide_exon_with_intron_partial_venn.txt 

for i in $(seq -f %02.0f 1 10); 
do
    DIR=CHR_${i}/sgeval_${DATE}_chr${i}
    cat ${DIR}/${VENN} | perl venn.pl
    echo;
done
