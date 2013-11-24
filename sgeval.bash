#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    sgeval.bash                                             #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Runs sgeval.pl for two predictors (mainly AUGUSTUS and  #
#             MYOP) against PASA, over the 10 chromossomes. Outputs   #
#             are put in sgeval_yyyy_mm_dd_chrXX directory.           #
# date:       26/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ############################################################
DATE=$(date +"%Y_%m_%d")
PASA_DATE=2013_07_08

## SCRIPT ##############################################################
# Store beginnig of the process
date > sgeval.date

# Log message
echolog "Running sgeval for each chromossome alone"

# Runs SGEval for 2 predictors (MYOP and AUGUSTUS)
for i in $(seq -f %02.0f 6 10); 
do
    PASA_PATH=.
    PASA_FILE=Sb_${PASA_DATE}_chr${i}_pasa.gtf

    PRD1_PATH=.
    PRD1_FILE=augustus_chr${i}.gtf.clean.new

    PRD2_PATH=.
    PRD2_FILE=myop_chr${i}.gtf.clean.new.cor

    cd CHR_${i} # Gets into the chromossomes dir.
    
    # Creates a sgeval results file
    OUTDIR=sgeval_${DATE}_chr${i}
    mkdir -p ${OUTDIR}
    
    # Runs SGEval for each chromossome specified 
    date > ${OUTDIR}/sgeval_${DATE}_chr${i}.date  \
    &&                                            \
    nice sgeval.pl -o ${OUTDIR}                   \
        -g ${PASA_PATH}/${PASA_FILE}              \
        ${PRD1_PATH}/${PRD1_FILE}                 \
        ${PRD2_PATH}/${PRD2_FILE}                 \
        1> ${OUTDIR}/sgeval_analysis_${DATE}.log  \
        2> ${OUTDIR}/sgeval_analysis_${DATE}.err  \
    &&                                            \
    date >> ${OUTDIR}/sgeval_${DATE}_chr${i}.date &
    
    cd .. # Leaves the chromossomes dir.
done

# Store end of the process
date >> sgeval.date
