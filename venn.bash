#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    venn.bash                                               #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Runs venn.pl twice: the first, for creating all the     #
#             textual venn diagram; the second, pipeing the output    #
#             for getting the data with accuracy.pl.                  #
# date:       26/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ###########################################################
DATE=2013_09_22
VENN=nucleotide_exon_with_intron_partial_venn.txt 
DIR=CHR_*/sgeval_${DATE}_chr*

## SCRIPT #############################################################
echolog "== NUCLEOTIDES =============================================="
echolog
perl venn.pl ${DIR}/${VENN} 
echolog
perl venn.pl ${DIR}/${VENN} | perl accuracy.pl 2> /dev/null

echolog
echolog "== EXON ====================================================="
echolog
perl venn.pl ${DIR}/nucleotide_exon_venn.txt
echolog
perl venn.pl ${DIR}/nucleotide_exon_venn.txt | perl accuracy.pl 2> /dev/null

echolog
echolog "== GENE ====================================================="
echolog
perl venn.pl ${DIR}/gene_exact_venn.txt
echolog
perl venn.pl ${DIR}/gene_exact_venn.txt | perl accuracy.pl 2> /dev/null
