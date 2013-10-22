#!/usr/bin/perl
use v5.10;

#######################################################################
# Program:    stop_codons.pl                                          #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Gets a .pep file and separates its entries in two       #
#             groups (each one with a new file): SHORT - predictions  #
#             with stop codons whithin it (represented by *); and     #
#             LONG - with no stop codons inside.                      #
# date:       24/10/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;

# Preamble
my $USAGE = "stop_codon_analyse.pl pep_file.pep shorts_file.pep.short";

# Usage
die "\n$USAGE\n" if(scalar @ARGV != 2);

# Arguments
my $pep_file       = shift @ARGV;
my $pep_short_file = shift @ARGV;

# Runs seqstat
my $pep_stat   = qx/seqstat $pep_file/;
my $short_stat = qx/seqstat $pep_short_file/;

# Split lines
my @pep_stat   = split /\n/, $pep_stat;
my @short_stat = split /\n/, $short_stat;

my ($pep_format, 
    $pep_type, 
    $pep_num_seq, 
    $pep_residues, 
    $pep_smallest, 
    $pep_largest, 
    $pep_length) = @pep_stat[5 .. 11];

my ($short_format, 
    $short_type, 
    $short_num_seq, 
    $short_residues, 
    $short_smallest, 
    $short_largest, 
    $short_length) = @short_stat[5 .. 11];

# Process data for the results
$pep_file =~ s/\.pep//;
$pep_num_seq   =~ /.*:\s+(\d+)/; $pep_num_seq   = $1;
$short_num_seq =~ /.*:\s+(\d+)/; $short_num_seq = $1;

printf "%s: %0.6f %%\n", $pep_file, 100*$short_num_seq/$pep_num_seq;
