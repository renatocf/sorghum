#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

## PREAMBLE ###########################################################
DATE=2013_07_30
VENN=nucleotide_exon_with_intron_partial_venn.txt 
DIR=CHR_*/sgeval_${DATE}_chr*

## SCRIPT #############################################################
perl venn.pl ${DIR}/${VENN} 
echolog
perl venn.pl ${DIR}/${VENN} | perl accuracy.pl 2> /dev/null
