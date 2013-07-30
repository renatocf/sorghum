#!/usr/bin/perl

use strict;
use warnings;

my %nucleotides = ();
my $pred_msize = 0;
my $nucl_msize = 0;

my $total = 0;
foreach my $file (@ARGV)
{
    open(FILE, "<", $file);
    
    $file =~ s/CHR_\d\d\///g;
    $file =~ s/_chr\d\d.*//g;
    my $s = length $file;
    ($s > $pred_msize) ? ($pred_msize = $s) : ();
    
    while(my $line = <FILE>)
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
            
            if ($start >= $end) {
                $nucleotides{$file} += $start - $end + 1;
            }
            else {
                $nucleotides{$file} += $end - $start + 1;
            }
        } # if
    } # while
    close FILE;
}

# Process all numbers in a more legible format
foreach my $pred (keys %nucleotides)
{
    # Creates an array with the numeric part of the sentence.
    # The aim is to make more legible numbers
    my @num = split("", $nucleotides{$pred});
    my $size = scalar @num;
    
    # Last digit multiple of 3
    my $dif = $size % 3;
    
    # Prints untill reaches the last digit multiple of 3
    # and, then, to each multiple, prints a '.'
    # E.g. 31415 - the last multiple is 4 and it prints 31,
    #              then puts a '.' and prints 415
    $nucleotides{$pred} = "";
    for(my $j = -$dif, my $i = 0; $i != $size; $i++, $j++) 
    { 
        $nucleotides{$pred} .= "." unless( ($j % 3) > 0 || !$i );
        $nucleotides{$pred} .= "$num[$i]"; 
    }
    
    # Takes the biggest size of the numbers to print it later
    my $s = length $nucleotides{$pred};
    ($s > $nucl_msize) ? ($nucl_msize = $s) : ();
}

foreach my $pred (sort keys %nucleotides) {
    printf "%-*s TOTAL BASES = %*s\n", $pred_msize, $pred, 
                                       $nucl_msize, $nucleotides{$pred};
}
