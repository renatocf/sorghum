#!/usr/bin/perl
package main;
use v5.10;

#######################################################################
# Program:    nucleotide.pl                                           #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets the output of venn.pl and prints      # 
#             the number of nucleotides predicted by each predictor   #
#             that is different from pasa.                            #
# date:       08/08/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;

## GLOBAL VARIABLES ###################################################
my %hash = ();
my $key_msize = 0;
my $num_msize = 0;

## SCRIPT #############################################################
LINE: while(my $line = <>)
{
    (my $name, my $quantity) = split(/=>/, $line);
    $name =~ s/ //g;      # Taking out spaces
    $quantity =~ s/ //g;  # Taking out spaces
    $quantity =~ s/\.//g; # Taking out dots
    
    # DEBUG: print the complete sentence
    print STDERR "SENTENCE ==> $name\n";
    
    my @fields = split(/\|/, $name);
    FIELD: for my $field (@fields)
    {
        if($field !~ /pasa/ and $field !~ /pasa_intron/)
        {
            # DEBUG: print the identified field for the sentence
            print STDERR "$field\n";
            $hash{$field} += $quantity;
            
            # Takes the biggest size of the keys to print it later
            my $s = length $field;
            ($s > $key_msize) ? ($key_msize = $s) : ();
        }
    }
    
    # DEBUG: print a separation
    print STDERR "\n";
}

NUM: foreach (values %hash)
{
    my $size = 0; 
    $size += 4 while(s/(.*)(\d)(\d{3})/$1$2.$3/);
    $size += ($size != 0) ? (1 + length $1) : (length);
    ($size > $num_msize) ? ($num_msize = $size) : ()
}

PRINT: for my $key (sort keys %hash) 
{
    # Prints all the keys in the following format:
    # pred nucleotides = 23.543.354.134
    printf "%-*s nucleotides = %*s\n", $key_msize, $key, 
                                       $num_msize, $hash{$key};
}
