#!/bin/bash
echolog() { echo "$@"; }
echoerr() { echo "$@" 1>&2; }

#######################################################################
# Program:    myop-cor_gtf_to_cds.bash                                #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Runs myop-cor_gtf_to_cds.pl in all chromossomes of the  #
#             genome, which generate the .cor files on their          #
#             respective directories.                                 #
# date:       24/11/13 (dd/mm/yy)                                     #
#######################################################################

for i in $(seq -f %02.0f 1 10); 
do 
    echo "CHR_${i}"
    perl myop-cor_gtf_to_cds.pl             \
    -g CHR_${i}/myop_chr${i}.gtf.clean.new  \
    -f CHR_${i}/CHR_${i}_RefSeq.fasta       \
    1> CHR_${i}/myop_chr${i}.fa             \
    2> /dev/null
done
