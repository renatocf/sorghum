#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    augustus.bash                                           #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program runs a pipeline over all the chromossomes  #
#             directories to get the predictions made by augustus.    #
# date:       08/07/13 (dd/mm/yy)                                     #
#######################################################################

# TODO: Still need to find a way of, as soon as one of the processes
#       is finished, run the other step (without just using comments
#       in the code). 
# TODO: Calculate, given the maximum number of procesors, how many 
#       files could be run in parallel

## PREAMBLE ############################################################
n_chr=10
species=maize

## AUGUSTUS ############################################################
for i in $(seq -f %02.0f ${n_chr}); 
do 
    # Run augustus for 'n_chr' chromossomes based on species 'species'
    date > CHR_${i}/augustus_chr${i}.date  \
    &&                                     \
    nice augustus --species=$species       \
    CHR_${i}/CHR_${i}_RefSeq.fasta         \
    1> CHR_${i}/augustus_chr${i}.gtf       \
    2> CHR_${i}/augustus_chr${i}.err       \
    &&                                     \
    date >> CHR_${i}/augustus_chr${i}.date &
done

## REMOVE MAPPED #######################################################
for i in $(seq -f %02.0f ${n_chr}); 
do
    # Runs 'remove_mapped.pl' to clean all the .gtf
    perl remove_mapped.pl augustus           \
       CHR_${i}/augustus_chr${i}.gtf         \
       CHR_${i}/CHR_${i}_RefSeq.fasta.map    \
    1> CHR_${i}/augustus_chr${i}.gtf.clean   \
    2> CHR_${i}/augustus_chr${i}.gtf.removed &
done

## JOIN CHROMOSSOMES ###################################################
# Runs 'join_chrs.pl' to create an unique cleant .gtf
perl join_chrs.pl augustus < augustus.data
