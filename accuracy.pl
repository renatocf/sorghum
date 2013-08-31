#!/usr/bin/perl 
package main;
use v5.10;

#######################################################################
# Program:    accuracy.pl                                             #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets the output of venn.pl and calculates  #
#             some statiscical information about it (TP. TN, FP, FN,  #
#             accuracy and specificity).
# date:       25/07/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;

## GLOBAL VARIABLES ###################################################
my %hash = ();
my $key_msize = 0;
my $num_msize = 0;

my $pasa = 0;
my $pasa_intron = 0;

## SCRIPT #############################################################
while(my $line = <>)
{
    chomp $line; # Takes out \n
    
    (my $name, my $quantity) = split(/=>/, $line);
    $name =~ s/ //g;      # Taking out spaces
    $quantity =~ s/ //g;  # Taking out spaces
    $quantity =~ s/\.//g; # Taking out dots
    
    # DEBUG: print the complete sentence
    say STDERR "SENTENCE ==> $name";
    
    my @fields = split(/\|/, $name);
    my $p_exon = 0; my $p_intron = 0;
    
    if($name =~ m/pasa([^_]|$)/) { 
        $p_exon = 1; 
        $pasa += $quantity;
        
        # DEBUG: print pasa exon added quantity
        say STDERR "  pasa exon: +$quantity";
    } 
    elsif($name =~ m/pasa_intron/) { 
        $p_intron = 1; 
        $pasa_intron += $quantity;
        
        # DEBUG: print pasa_intron added quantity
        say STDERR "  pasa intron: +$quantity";
    } 
    
    foreach my $field (@fields)
    {
        # DEBUG: print the field
        print STDERR "  field ==> $field\n";
        
        unless($field =~ /pasa/ or $field =~ /pasa_intron/)
        {
            if($p_exon)
            {
                # TP: True positive
                # Everything that is pasa exon and was 
                # predicted by some predictor
                $hash{$field}{'TP'} += $quantity;
                print STDERR "    ($field) TP: +$quantity\n";
            }
            if($p_intron)
            {    
                # FP: False positive
                # Everything that is pasa_intron, not in pasa
                # exon, but was predicted by some predictor
                $hash{$field}{'FP'} += $quantity;
                print STDERR "    ($field) FP: +$quantity\n";
            }
        } # unless
        
        # Takes the biggest size of the keys to print it later
        my $s = length $field;
        ($s > $key_msize) ? ($key_msize = $s) : ();
        
    } #foreach pred
    
    # DEBUG: print a separation
    print STDERR "\n";
}               

foreach my $pred (keys(%hash)) 
{
    # Calculate TN and FN from TP/FP and the total
    # values of pasa exons and pasa introns
    
    # FN: False negative
    # Everything that is pasa exon but was not predicted by 
    # the preditor (or all the pasa exon minus the ones that 
    # were predicted by this predictor - def. of True Positive)
    $hash{$pred}{'FN'} = $pasa - $hash{$pred}{'TP'};
    
    # TN: True negative
    # Everything that is pasa_intron but was not predicted by 
    # the predictor (or all the pasa_intron minus the ones that
    # were predicted by this predictor - def. of False Positive)
    $hash{$pred}{'TN'} = $pasa_intron - $hash{$pred}{'FP'};
    
    foreach my $key (keys %{$hash{$pred}})
    {
        # Creates an array with the numeric part of the sentence.
        # The aim is to make more legible numbers
        my @num = split("", $hash{$pred}{$key});
        my $size = scalar @num;
        
        # Last digit multiple of 3
        my $dif = $size % 3;
        
        # Prints untill reaches the last digit multiple of 3
        # and, then, to each multiple, prints a '.'
        # E.g. 31415 - the last multiple is 4 and it prints 31,
        #              then puts a '.' and prints 415
        $hash{$pred}{$key} = "";
        for(my $j = -$dif, my $i = 0; $i != $size; $i++, $j++) 
        { 
            $hash{$pred}{$key} .= "." unless( ($j % 3) > 0 || !$i );
            $hash{$pred}{$key} .= "$num[$i]"; 
        }
        
        # Takes the biggest size of the numbers to print it later
        my $s = length $hash{$pred}{$key};
        ($s > $num_msize) ? ($num_msize = $s) : ();
    }
}

foreach my $pred (sort keys %hash) 
{
    print "$pred\n";
    (my $TP = $hash{$pred}{'TP'}) =~ s/\.//g;
    (my $TN = $hash{$pred}{'TN'}) =~ s/\.//g;
    (my $FP = $hash{$pred}{'FP'}) =~ s/\.//g;
    (my $FN = $hash{$pred}{'FN'}) =~ s/\.//g;
    my $sensibility = $TP/($TP+$FN); # True positive / All positives
    my $specificity = $TN/($TN+$FP); # True negative / All negatives
    
    foreach my $key (keys %{$hash{$pred}})
    {
        # Prints all the keys in the following format:
        # pred nucleotides = 23.543.354.134
        printf "  %-*s => %*s\n", 11, $key, 
                                  $num_msize, $hash{$pred}{$key};
    }
    printf "  %s => %*g (%2.2d%%)\n", "sensibility", $num_msize, 
                                       $sensibility, $sensibility*100;
    printf "  %s => %*g (%2.2d%%)\n", "specificity", $num_msize, 
                                       $specificity, $specificity*100;
    print "//\n"
}
