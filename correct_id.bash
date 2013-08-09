#!/bin/bash

# Myop predictor
perl correct_id.pl MYOP CHR*/myop_chr*.gtf.clean

# Augustus predictor
perl correct_id.pl AUGUSTUS CHR*/augustus_chr*.gtf.clean
