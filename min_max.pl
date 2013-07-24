#!/usr/bin/perl

#######################################################################
# Program:    min_max.pl                                              #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets a .gtf file from stdin and finds      # 
#             the biggest and smallest 'start' entry among all the    #
#             predictions.                                            #
# date:       06/07/13 (dd/mm/yy)                                     #
#######################################################################

use strict;
use warnings;

my $min = undef;
my $max = undef;

while(my $line = <>)
{
    chomp $line; # Remove EOL
    
    if($line =~ m/^\s*\#/          # Augustus comments
    or $line =~ m/^\s*$/) { next } # Myop spaces
    
    (my $seqname, 
     my $source, 
     my $feature, 
     my $start, 
     my $end, 
     my $score, 
     my $strand, 
     my $frame, 
     my $attribute) = split("\t",$line);
    
    if(!defined $min and !defined $max) { $min = $max = $start; }
    if($start < $min) { $min = $start; }
    if($start > $max) { $max = $start; }
}

print "Minimum start: $min \n";
print "Maximum start: $max \n";
