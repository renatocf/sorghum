#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    stop_codons.bash                                        #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Takes MYOP predictions, convert them to peptides and    #
#             divide them in two files: one with the ones that have   #
#             stop codons in the middle, and another with the         #
#             remaining sequences. Then, uses seqstat to generate     #
#             statistics about the proportions of these genes.        #
# date:       21/10/13 (dd/mm/yy)                                     #
#######################################################################

# # Runs stop_codon.pl to get the predictor
# # sequences from the input.
# for i in $(seq -f %02.0f 10); 
# do 
#     echolog "CHR_${i}"
#     myop-gtf_to_cds.pl                      \
#     -g CHR_${i}/myop_chr${i}.gtf.clean.new  \
#     -f CHR_${i}/CHR_${i}_RefSeq.fasta       \
#     1> CHR_${i}/myop_chr${i}.fasta
# done 
# 
# # Runs transeq for generating chromossomes
# for i in $(seq -f %02.0f 10); 
# do 
#     transeq CHR_${i}/myop_chr${i}.fasta \
#     -outseq CHR_${i}/myop_chr${i}.pep
# done
# 
# # Count number of stop codons
# echolog "Counting number of stop codons"
# for i in $(seq -f %02.0f 10); 
# do
#     echolog "CHR_${i}"
#     perl stop_codons.pl                 \
#     <  CHR_${i}/myop_chr${i}.pep        \
#     1> CHR_${i}/myop_chr${i}.pep.long   \
#     2> CHR_${i}/myop_chr${i}.pep.short
# done

# Creates stop_codon.data with the results.
echo > stop_codons.data
echo "Stop codon statistics"         >> stop_codons.data
echo "=============================" >> stop_codons.data
for i in $(seq -f %02.0f 10); 
do
    perl stop_codons_analyse.pl     \
    CHR_${i}/myop_chr${i}.pep       \
    CHR_${i}/myop_chr${i}.pep.short \
    >> stop_codons.data
done
