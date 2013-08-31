#!/usr/bin/perl
package main;
use v5.10;

#######################################################################
# Program:    join_chrs.pl                                            #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets a preditor name and a .data file as   # 
#             input. For each line of the data file (specified above) #
#             it calls iteratively add_quantity.pl to sum SIZE in     #
#             each of the .gtf lines.                                 #
# date:       08/07/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;

## HELP/USAGE #########################################################
if(scalar(@ARGV) != 1) {
    die "Usage: join_chrs.pl <predictor>";
}

## GLOBAL VARIABLES ###################################################
# Read file of type <name file>:size
my $init = 0;
my $predictor = shift(@ARGV);
system("rm $predictor.gtf");

## SCRIPT #############################################################
LINE: while (my $line = <>)
{
    chomp($line);
    print $init, "\n";
    (my $file, my $size) = split(":", $line);
    system("perl add_quantity.pl $predictor $file $init ".
           "1>> $predictor.gtf 2>> $predictor.err");
    $init += $size;
}

# Generate file predictor.data: (MANUALLY)
# /home/user/predictor/chr01.gtf:34762453248
# /home/user/predictor/chr02.gtf:23633423456
# /home/user/predictor/chr03.gtf:16867373724
# /home/user/predictor/chr04.gtf:12647563242
# 
# Usage: 
# scriptacima.pl predictor < preditor.data
