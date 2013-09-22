#!/usr/bin/perl
package main;
use v5.10;

#######################################################################
# Program:    count_bases.pl                                          #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets .gtf files as arguments and for each  #
#             one, count the number of nucleotides presented on it.   #
# date:       08/08/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;

## GLOBAL VARIABLES ###################################################
my %nucleotides = ();
my $pred_msize = 0;
my $nucl_msize = 0;

## SCRIPT #############################################################
FILE: for my $file (@ARGV)
{
    my %first = (); 
    my %last = (); 
    
    open(FILE, "<", $file);
    
    # Takes out from the names directory 
    # path and digits informations
    $file =~ s/.*CHR_\d\d\///g;
    $file =~ s/_chr\d\d.*//g;
    
    # Save the length of the file names 
    # to print them in a better format later
    my $s = length $file;
    ($s > $pred_msize) ? ($pred_msize = $s) : ();
    
    LINE: while(my $line = <FILE>)
    {
        if ($line =~ m/\s+CDS\s+/)
        {
            # DEBUG: print line
            print STDERR $line;
            my @fields = split (/\s+/, $line);
            
            # Store beggining and end
            my $start = $fields[3];
            my $end  = $fields[4];
            
            # DEBUG: Print statr and end
            print STDERR "start=>$start, end=>$end\n"; 
            
            # Do not sum if the sequence is repeated
            unless(exists($first{$start}) and exists($last{$end}))
            {
                ($start >= $end) ?
                ($nucleotides{$file} += $start - $end + 1) :
                ($nucleotides{$file} += $end - $start + 1) ;
            }
            
            # Saving both references in the hashes
            $first{$start} = 1;
            $last{$end} = 1;
        } # if
    } # while
    close FILE;
}

# Process all numbers in a more legible format
NUM: foreach (values %nucleotides)
{
    my $size = 0;
    $size += 4 while(s/(.*)(\d)(\d{3})/$1$2.$3/);
    $size += ($size != 0) ? (1 + length $1) : (length);
    ($size > $nucl_msize) ? ($nucl_msize = $size) : ()
}

PRINT: for my $pred (sort keys %nucleotides) {
    printf "%-*s TOTAL BASES = %*s\n", $pred_msize, $pred, 
                                       $nucl_msize, $nucleotides{$pred};
}
