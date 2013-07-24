#!/bin/bash
echoerr() { echo "$@" 1>&2; }

## PREAMBLE ############################################################
n_chr=10
species=maize

## AUGUSTUS ############################################################
for i in $(seq -f %02.0f ${n_chr}); 
do 
    # Run augustus for 'n_chr' chromossomes based on species 'species'
    $(date > CHR_${i}/augustus.date \
      && augustus --species=$species CHR_${i}/CHR_${i}_RefSeq.fasta \
      > CHR_${i}/augustus_chr${i}.gtf 2> CHR_${i}/augustus.err \
      && date >> CHR_${i}/augustus.date); 
done

## REMOVE MAPPED #######################################################
for i in $(seq -f %02.0f ${n_chr}); 
do
    # Runs 'remove_mapped.pl' to clean all the .gtf
    $(perl remove_mapped.pl augustus \
    CHR_${i}/augustus_chr${i}.gtf CHR_${i}_RefSeq.fasta.map \
    > CHR_${i}/augustus_chr${i}.gtf.clean 2> CHR_${i}/remove.err);
done

## JOIN CHROMOSSOMES ###################################################
# Runs 'join_chrs.pl' to create an unique cleant .gtf
perl join_chrs.pl augustus < augustus.data
