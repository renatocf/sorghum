#!/usr/bin/perl

use strict;
use warnings;

my %hash = ();
my $key_msize = 0;
my $num_msize = 0;

# Getting all files to be processed
foreach my $file (@ARGV)
{
    open(FILE, "<", $file);
    while(my $exp = <FILE>) 
    { 
        # All the // or sequences are taken off
        next if($exp =~ /^\t|\/\//);
        chomp $exp; # Taking out '\n'
        
        # Splitting the sentence in 2 parts: groups and numbers
        my ($key, $number) = split("\t", $exp); 
        
        # Splits fields and sort them
        my @fields = split(/\|/, $key);
        foreach my $field (@fields)
        {
            $field =~ s/\_chr\d\d//g;
            $field =~ s/\.clean\..*//g;
            $field =~ s/Sb.*pasa/pasa/;
        }
        $key = join("|",sort(@fields));
        
        # Stores in the hash
        $hash{$key} += $number;
        
        # Takes the biggest size of the keys to print it later
        my $s = length $key;
        ($s > $key_msize) ? ($key_msize = $s) : ();
    }
    close FILE;
}

# Process all numbers in a more legible format
foreach my $key (keys(%hash))
{
    # Creates an array with the numeric part of the sentence.
    # The aim is to make more legible numbers
    my @num = split("", $hash{$key});
    my $size = scalar @num;
    
    # Last digit multiple of 3
    my $dif = $size % 3;
    
    # Prints untill reaches the last digit multiple of 3
    # and, then, to each multiple, prints a '.'
    # E.g. 31415 - the last multiple is 4 and it prints 31,
    #              then puts a '.' and prints 415
    $hash{$key} = "";
    for(my $j = -$dif, my $i = 0; $i != $size; $i++, $j++) 
    { 
        $hash{$key} .= "." unless( ($j % 3) > 0 || !$i );
        $hash{$key} .= "$num[$i]"; 
    }
    
    # Takes the biggest size of the numbers to print it later
    my $s = length $hash{$key};
    ($s > $num_msize) ? ($num_msize = $s) : ();
}

foreach my $key (sort keys(%hash)) 
{
    # Prints all the keys in the following format:
    # pred1|pred2|...|predn => 23.543.354.134
    printf "%-*s => %*s\n", $key_msize, $key, 
                            $num_msize, $hash{$key};
}
