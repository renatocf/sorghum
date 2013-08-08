#!/usr/bin/perl
use v5.10;

#######################################################################
# Program:    add_quantity.pl                                         #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets a .gtf file and adds to the 'start'   #
#             and 'end' fields of each line a quanty passed as an     #
#             argument. Also requiser the predictor name and .gtf     #
#             file name.                                              #
# date:       25/07/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use warnings;
use strict;
use bigint;

# Usage
if(scalar(@ARGV) != 3) {
    die "Usage: add_quantity.pl <predictor> <.gtf> <quantity>";
}

## VARIABLES ##########################################################
my $predictor = shift @ARGV;
my $gene_file = shift @ARGV;
my $quantity = shift @ARGV;

my $myop_delim = "\n\n";
my $pasa_delim = "\n\n";
my $augustus_delim = "\n###\n";

## SCRIPT #############################################################
# First we need the correct read delimiter
my $old_delim = $/;
given ($predictor)
{
    when (m/myop/i)     { $/ = $myop_delim; }
    when (m/pasa/i)     { $/ = $pasa_delim; }
    when (m/augustus/i) { $/ = $augustus_delim; }
    default 
    {
        die "gene predictor name not recognized",
            "(should be 'augustus' or 'myop'):$predictor\n";
    }
}

open(GENE, "<", $gene_file);
while(my $gene = <GENE>) 
{
    # Takes out \n from each line
    chomp $gene;
    
    my @lines = split("\n", $gene);
    LINES: for my $line (@lines) 
    {
        given($line)
        {
            # Ignore comments and blank lines
            when(m/^\s*\#/) { next LINES; }
            when(m/^\s*$/)  { print "$line\n"; next LINES; }
        }
        
        # Split .gtf line in its fields
        (my $seqname, 
         my $source, 
         my $feature, 
         my $start, 
         my $end, 
         my $score, 
         my $strand, 
         my $frame, 
         my $attribute) = split("\t",$line);
        
        # Add quantity to 'start' and 'end'
        $start += $quantity;
        $end += $quantity;
        
        # Join lines again and print
        $line = join("\t", $seqname, $source, $feature, $start,
                           $end, $score, $strand, $frame, $attribute);
        print "$line\n";
    }
    print "\n"; # Separate blocks with blank lines
}
close(GENE);
