#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    pasa05.bash                                             #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Fifth step of the pasa pipeline. Join all chromossomes  #
#             in a unique file, correcting the beggining of their     #
#             ids accordingly to pasa.data.                           #
# date:       09/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ############################################################
DATE=$(date +"%Y_%m_%d")
OUTDIR=sgeval_${DATE}

PASA_PATH=.
PASA_FILE=pasa.gtf

PRD1_PATH=.
PRD1_FILE=augustus.gtf

PRD2_PATH=.
PRD2_FILE=myop.gtf

## SCRIPT ##############################################################
# Store beginnig of the process
date > sgeval_ai1.date

# Create output dir
mkdir -p ${OUTDIR}

# Log message
echolog "Running sgeval for all chrs together"

# Runs SGEval for 2 predictors (MYOP and AUGUSTUS)
nice sgeval.pl -o ${OUTDIR} \
    -g ${PASA_PATH}/${PASA_FILE} \
    ${PRD1_PATH}/${PRD1_FILE} \
    ${PRD2_PATH}/${PRD2_FILE} \
    1> ${OUTDIR}/sgeval_analysis_${DATE}.log \
    2> ${OUTDIR}/sgeval_analysis_${DATE}.err
RES=$?

# Error message
if [ "$RES" -ne "0" ]; 
then 
    echoerr "Problems while running SGEval"
    echoerr "Exit with status $RES"
fi

# Store end of the process
date >> sgeval_ai1.date

# Puts all the files in the directory
mv sgeval_ai1.date ${OUTDIR}
