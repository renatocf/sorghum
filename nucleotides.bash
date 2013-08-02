#!/bin/bash
echolog() { echo "$@"; } #1>results.txt; }
echoerr() { echo "$@" 1>&2; }

n_chr=10

echolog "Relatório de nucleotídeos"
echolog

for i in $(seq -f %02.0f ${n_chr}); 
do
    DATE=2013_07_30
    MYOP=myop_chr${i}.gtf.clean.new 
    AUGUSTUS=augustus_chr${i}.gtf.clean.new 
    VENN=nucleotide_exon_with_intron_partial_venn.txt 
    ACCURACY=nucleotide_exon_with_intron_partial_accuracy.txt 
    
    cd CHR_${i}
    echolog "CHR_${i}"
    echolog "---------------------------"
    
    echolog "Somando a partir do SGEval:"
    perl ../venn.pl sgeval_${DATE}_chr${i}/${VENN} \
        | perl ../nucleotide.pl 2> /dev/null
    echolog
    
    echolog "Contando CDS:"
    perl ../count_bases.pl ${MYOP} ${AUGUSTUS} 2> /dev/null
    echolog
    
    # cat sgeval_2013_07_29_chr${i}/${ACCURACY}
    # echolog
    cd ..
done
