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
DATE=2013_07_30
VENN=nucleotide_exon_with_intron_partial_venn.txt 
DIR=CHR_*/sgeval_${DATE}_chr*

## SCRIPT #############################################################
perl venn.pl ${DIR}/${VENN} 
echolog
perl venn.pl ${DIR}/${VENN} | perl accuracy.pl 2> /dev/null
