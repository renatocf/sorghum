#!/usr/bin/perl

use strict;
use warnings;

my $i = undef;
my $j = undef;
my $exp = undef;
my $group = undef;
my $number = undef;

while($exp = <>) 
{ 
    unless($exp =~ /^\t|\/\//) 
    { 
        chomp $exp; # Taking out '\n'
        
        # Splitting the sentence in 2 parts: groups and numbers
        ($group, $number) = split("\t", $exp); 
        
        # Firt part is printed 'as it'
        print "$group\t"; 
        
        # Creates an array with the numeric part of the sentence.
        # The aim is to make more legible numbers
        my @num = split("", $number);
        my $size = scalar @num;
        
        # Last digit multiple of 3
        my $dif = $size % 3;
        
        # Prints untill reaches the last digit multiple of 3
        # and, then, to each multiple, prints a '.'
        # E.g. 31415 - the last multiple is 4 and it prints 31,
        #              then puts a '.' and prints 415
        for($j = -$dif, $i = 0; $i != $size; $i++, $j++) 
        { 
            print "." unless( ($j % 3) > 0 | !$i );
            print $num[$i]; 
        }
        
        print "\n";
    } 
}
