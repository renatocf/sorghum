#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    nucleotides_together.bash                               #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Compares the number of nucleotides from the outputs     #
#             from MYOP and AUGUSTUS against the numbers predicted    #
#             by SGEVAL (comparing the predictions made together).    #
# date:       30/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ############################################################
DATE=2013_07_30
MYOP=myop_chr*.gtf.clean.new 
AUGUSTUS=augustus_chr*.gtf.clean.new 
VENN=nucleotide_exon_with_intron_partial_venn.txt 
ACCURACY=nucleotide_exon_with_intron_partial_accuracy.txt 

## SCRIPT ##############################################################
echolog "Relatório de nucleotídeos"
echolog

echolog "Somando a partir do SGEval:"
perl venn.pl CHR_*/sgeval_${DATE}_chr*/${VENN} \
    | perl nucleotide.pl 2> /dev/null
echolog

echolog "Contando CDS:"
perl count_bases.pl CHR_*/${MYOP} CHR_*/${AUGUSTUS} 2> /dev/null
echolog
