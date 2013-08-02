#!/bin/bash
echolog() { echo "$@"; } #1>results.txt; }
echoerr() { echo "$@" 1>&2; }

echolog "Relatório de nucleotídeos"
echolog

DATE=2013_07_30
MYOP=myop_chr*.gtf.clean.new 
AUGUSTUS=augustus_chr*.gtf.clean.new 
VENN=nucleotide_exon_with_intron_partial_venn.txt 
ACCURACY=nucleotide_exon_with_intron_partial_accuracy.txt 

echolog "Somando a partir do SGEval:"
perl venn.pl CHR_*/sgeval_${DATE}_chr*/${VENN} \
    | perl nucleotide.pl 2> /dev/null
echolog

echolog "Contando CDS:"
perl count_bases.pl CHR_*/${MYOP} CHR_*/${AUGUSTUS} 2> /dev/null
echolog
