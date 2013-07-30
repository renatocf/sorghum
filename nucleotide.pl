#!/usr/bin/perl

use strict;
use warnings;

my %hash = ();
my $key_msize = 0;
my $num_msize = 0;

while(my $line = <>)
{
    (my $name, my $quantity) = split(/=>/, $line);
    $name =~ s/ //g;      # Taking out spaces
    $quantity =~ s/ //g;  # Taking out spaces
    $quantity =~ s/\.//g; # Taking out dots
    
    # DEBUG: print the complete sentence
    print STDERR "SENTENCE ==> $name\n";
    
    my @fields = split(/\|/, $name);
    foreach my $field (@fields)
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

foreach my $key (sort keys %hash) 
{
    # Prints all the keys in the following format:
    # pred nucleotides = 23.543.354.134
    printf "%-*s nucleotides = %*s\n", $key_msize, $key, 
                                       $num_msize, $hash{$key};
}
