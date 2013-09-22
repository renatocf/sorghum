#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    myop_iterative.bash                                     #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program runs an iterative version of myop over     #
#             all chromossomes, putting the results inside specific   #
#             directories created by myop-iteractive_training.pl      #
# date:       08/07/13 (dd/mm/yy)                                     #
#######################################################################

DATE=$(date +"%Y_%m_%d")
TRAINING_DIR=/home3/renatocf/sorghum/MYOP/myop_maize_2100/

N_OF_CPUS=1
N_OF_ITERATIONS=8

date > myop_iterative.date
for i in $(seq -f %02.0f 1 1); 
do
    cd CHR_${i} # Gets into the chromossomes dir.
    
    LOG_FILE=myop_iterative_chr${i}.log
    ERR_FILE=myop_iterative_chr${i}.err 
    DATE_FILE=myop_iterative_chr${i}.date 
    FASTA_FILE=CHR_${i}_RefSeq.fasta
    
    OUTPUT_DIR=myop_iterative_${DATE}_chr${i}
    date > ${DATE_FILE}
    
    # Run myop_iterative for a specific genome
    nice myop-iterative_training.pl \
        -f ${FASTA_FILE}        \
        -p ${TRAINING_DIR}      \
        -i ${N_OF_ITERATIONS}   \
        -o ${OUTPUT_DIR}        \
        -c ${N_OF_CPUS}         \
        1> ${LOG_FILE}          \
        2> ${ERR_FILE}          \
        && date >> ${DATE_FILE} \
        || echoerr "Problems while running SGEval" &
    RES=$?
    
    cd .. # Leaves the chromossomes dir.
done
date >> myop_iterative.date
