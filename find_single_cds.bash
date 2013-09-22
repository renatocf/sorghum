#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    find_single_cds.bash                                    #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Runs find_single_cds.bash over all pasa, augustus and   #
#             myop gtfs for generating .single and .multiple files    #
#             with the predictions which have 1 or more CDS.          #
# date:       06/08/13 (dd/mm/yy)                                     #
#######################################################################

DATE=2013_07_08
perl find_single_cds.pl -a CHR_*/Sb_${DATE}_chr*_pasa.gtf
perl find_single_cds.pl -a CHR_*/myop_chr*.gtf.clean.new
perl find_single_cds.pl -a CHR_*/augustus_chr*.gtf.clean.new
