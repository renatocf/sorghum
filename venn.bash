#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

DATE=2013_07_26
VENN=nucleotide_exon_with_intron_partial_venn.txt 

DIR=CHR_*/sgeval_${DATE}_chr*
perl venn.pl ${DIR}/${VENN} 
