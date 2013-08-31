#!/bin/bash

DATE=2013_07_08
perl find_single_cds.pl -a CHR_*/Sb_${DATE}_chr*_pasa.gtf
perl find_single_cds.pl -a CHR_*/myop_chr*.gtf.clean.new
perl find_single_cds.pl -a CHR_*/augustus_chr*.gtf.clean.new
