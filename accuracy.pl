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
    
    # If there is pasa exon, it will add in the quantity
    # of TRUE POSITIVE for a given predictor (ignoring 
    # if there is pasa_intron). Otherwise, we sum the
    # values as being an error.
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
        
        # To any field that is not pasa or pasa_intron,
        # sum to TRUE POSITIVES or FALSE POSITIVES as 
        # there we identified the presence of pasa_exon
        # or pasa_intron.
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

    # Stores the numeric values
    my ($TP, $TN) = ($hash{$pred}{'TP'}, $hash{$pred}{'TN'});
    my ($FP, $FN) = ($hash{$pred}{'FP'}, $hash{$pred}{'FN'});
    
    # Process all numbers in a more legible format
    foreach (values %{$hash{$pred}})
    {
        my $size = 0;
        $size += 4 while(s/(.*)(\d)(\d{3})/$1$2.$3/);
        $size += ($size != 0) ? (1 + length $1) : (length);
        ($size > $num_msize) ? ($num_msize = $size) : ()
    }
    
    # Sensibility: True positive / All positives
    # Specificity: True negative / All negatives
    $hash{$pred}{'sensibility'} = $TP/($TP+$FN); 
    $hash{$pred}{'specificity'} = $TN/($TN+$FP); 
}

foreach my $pred (sort keys %hash) 
{
    # Stores sensibility and specificity outside the hash
    my $sensibility = delete $hash{$pred}{'sensibility'};
    my $specificity = delete $hash{$pred}{'specificity'};
    
    print "$pred\n";
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
