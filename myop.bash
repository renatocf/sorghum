#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    myop.bash                                               #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program runs a pipeline over all the chromossomes  #
#             directories to get all the predictions made by the      #
#             MYOP predictor.                                         #
# date:       08/07/13 (dd/mm/yy)                                     #
#######################################################################

## PREAMBLE ############################################################
myop=/home/yoshiaki/myop/scripts/myop-predict.pl 
base=/home3/renatocf/sorghum/MYOP/myop_maize_2100/ 
n_chr=10
threads=4

## MYOP ################################################################
for i in $(seq -f %02.0f ${n_chr}); 
do 
    # Runs 'myop' in 'n_chr' chromossomes for 
    # a 'base' organism in 'threads' threads
    $(date > CHR_${i}/myop.date \
    && ${myop} -p ${base} -c ${threads} \
    -f CHR_${i}/CHR_${i}_RefSeq.fasta \
    > CHR_${i}/myop_chr${i}.gtf 2> CHR_${i}/myop.err \
    && date >> CHR_${i}/myop.date); 
done

## REMOVE MAPPED #######################################################
for i in $(seq -f %02.0f ${n_chr}); 
do
    # cd CHR_${i}
    # Runs 'remove_mapped.pl' to clean all the .gtf
    $(perl remove_mapped.pl myop \
    CHR_${i}/myop_chr${i}.gtf CHR_${i}/CHR_${i}_RefSeq.fasta.map \
    > CHR_${i}/myop_chr${i}.gtf.clean 2> CHR_${i}/remove.err);
    # cd ..
done

## JOIN CHROMOSSOMES ###################################################
# Runs 'join_chrs.pl' to create an unique cleant .gtf
perl join_chrs.pl myop < myop.data
