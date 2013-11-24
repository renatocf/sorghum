#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    venn.bash                                               #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Runs venn.pl twice: the first, for creating all the     #
#             textual venn diagram; the second, pipeing the output    #
#             for getting the data with accuracy.pl. The files are    #
#             generated for all nucleotides, exon nucleotides and     #
#             gene structures.                                        #
# date:       26/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ###########################################################
DATE=2013_11_24
DIR=CHR_*/sgeval_${DATE}_chr*
NUCL=nucleotide_exon_with_intron_partial_venn.txt 
EXON=exon_exact_venn.txt
GENE=gene_exact_venn.txt

## SCRIPT #############################################################
echolog "== NUCLEOTIDES =============================================="
echolog
perl venn.pl ${DIR}/${NUCL} 
echolog
perl venn.pl ${DIR}/${NUCL} | perl accuracy.pl 2> /dev/null

echolog
echolog "== EXON ====================================================="
echolog
perl venn.pl ${DIR}/${EXON}
echolog
perl venn.pl ${DIR}/${EXON} | perl accuracy.pl 2> /dev/null

echolog
echolog "== GENE ====================================================="
echolog
perl venn.pl ${DIR}/${GENE}
echolog
perl venn.pl ${DIR}/${GENE} | perl accuracy.pl 2> /dev/null
