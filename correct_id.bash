#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    correct_id.bash                                         #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program runs correct_id.pl for all gtf, for the    #
#             two predictors AUGUSTUS and MYOP, generating as output  #
#             gtf files with the ids corrected (with etension .new).  #
# date:       26/07/13 (dd/mm/yy)                                     #
#######################################################################

# Myop predictor
perl correct_id.pl MYOP CHR*/myop_chr*.gtf.clean

# Augustus predictor
perl correct_id.pl AUGUSTUS CHR*/augustus_chr*.gtf.clean
