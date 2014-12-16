#!/usr/bin/perl
use v5.10;

#######################################################################
# Program:    gene_size.pl                                            #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Runs over a .gtf file counting the number of genes per  #
#             size avaiable.                                          #
# date:       24/11/14 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;

# Usage
if(scalar(@ARGV) != 2) {
    die "Usage: $0 predictor file1.gtf file2.gtf ...\n";
}

## GLOBAL VARIABLES ###################################################
my $predictor = shift @ARGV;
my @gtf_files = @ARGV;

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

my %gene_size = ();

# Traverse all ftg files
for my $gtf_file (@gtf_files)
{
    open(GENE, "<", $gtf_file);
    while(my $gene = <GENE>) 
    {
        # Takes out \n from each line
        chomp $gene;
        
        my @lines = split("\n", $gene);
        my $count = 0;
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
            
            $count++ if $feature =~ m/CDS/i;
        }
        $gene_size{$count}++;
    }
    close(GENE);
}

my $gene_msize = 0;
my $coun_msize = 0;
my $total_coun = 0;

# Count number of digits of the maximum gene size
map { $gene_msize = length $_ if length $_ > $gene_msize } keys %gene_size;
$gene_msize = length "TOTAL" if length "TOTAL" > $gene_msize;

# Calculates total number of digits and process it in a legible format
map { $total_coun += $_; } values %gene_size;

# Process all numbers in a more legible format
NUM: foreach ((values %gene_size, $total_coun))
{
    my $size = 0;
    $size += 4 while(s/(.*)(\d)(\d{3})/$1$2_$3/);
    $size += ($size != 0) ? (1 + length $1) : (length);
    ($size > $coun_msize) ? ($coun_msize = $size) : ();
}

PRINT: for my $size (sort { $a <=> $b } keys %gene_size) 
{
    printf " %*s => %*s\n", $gene_msize, $size,
                            $coun_msize, $gene_size{$size};
}
printf " TOTAL => %*s\n", $coun_msize, $total_coun;
