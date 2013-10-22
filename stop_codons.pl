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

# Takes out first header
local $/ = ">";
<>;

FASTA: while ($single_fasta = <>)
{
    # Takes out '>'
    chomp($single_fasta);
    
    # Takes out header
    @lines = split("\n" , $single_fasta);
    $header = shift(@lines);
    $res = join("", @lines);
    
    # Prints SHORT in STDERR and LONG in STDOUT
    if ($res =~ m/\*/) { say STDERR ">$header SHORT\n$res"; }
    else               { say STDOUT ">$header LONG \n$res"; }
}
