#!/bin/bash

FASTA_DIR=../sorghum_data/Sorghum_bicolor.genome
FASTA_FILE=Sorghum_bicolor.genome.fa

TRAINING_DIR=../MYOP/myop_maize_2100/
OUTPUT_DIR=2013_30_04_iterative_training

N_OF_ITERATIONS=8
N_OF_CPUS=4

date >> myop_iterative.date
for i in $(seq -f %02.0f 1 5); 
do
    cd CHR_${i} # Gets into the chromossomes dir.
    
    LOG_FILE=myop_iterative_chr${i}.log
    ERR_FILE=myop_iterative_chr${i}.err 
    
    DATE_FILE=myop_iterative_chr${i}.date 
    date > ${DATE_FILE}
    
    # Run myop_iterative for a specific genome
    nice myop-iterative_training.pl \
        -f ${FASTA_FILE}      \
        -p ${TRAINING_DIR}    \
        -i ${N_OF_ITERATIONS} \
        -o ${OUTPUT_DIR}      \
        -c ${N_OF_CPUS}       \
        1> ${LOG_FILE}        \
        2> ${ERR_FILE}        &
    RES=$?
    
    # Error message
    if [ "$RES" -ne "0" ]; 
        then echoerr "Problems while running SGEval"
    else
        date >> ${DATE_FILE}
    fi
    
    cd .. # Leaves the chromossomes dir.
done
date >> myop_iterative.date
