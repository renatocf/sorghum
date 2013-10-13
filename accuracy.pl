#!/usr/bin/perl 
package main;
use v5.10;

#######################################################################
# Program:    accuracy.pl                                             #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets the output of venn.pl and calculates  #
#             some statiscical information about it (TP. TN, FP, FN,  #
#             accuracy and specificity).
# date:       13/10/13 (dd/mm/yy)                                     #
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
    $name =~ s/ //g;     # Taking out spaces
    $quantity =~ s/ //g; # Taking out spaces
    $quantity =~ s/_//g; # Taking out underscores
    
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
            else
            {    
                # FP: False positive
                # Everything that is pasa_intron, not in pasa
                # exon, but was predicted by some predictor
                $hash{$field}{'FP'} += $quantity;
                print STDERR "    ($field) FP: +$quantity\n";
            }
        
            # Takes the biggest size of the keys to print it later
            my $s = length $field;
            ($s > $key_msize) ? ($key_msize = $s) : ();
        } # unless
        
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

    # Stores the numeric values
    my $TP = $hash{$pred}{'TP'}; 
    my $FP = $hash{$pred}{'FP'};
    my $FN = $hash{$pred}{'FN'};
    
    # Total of predicted nucleotides
    $hash{$pred}{'predicted'} = $TP+$FP;
    
    # Process all numbers in a more legible format
    foreach (values %{$hash{$pred}})
    {
        my $size = 0;
        $size += 4 while(s/(.*)(\d)(\d{3})/$1$2_$3/);
        $size += ($size != 0) ? (1 + length $1) : (length);
        ($size > $num_msize) ? ($num_msize = $size) : ()
    }
    
    # Sensitivity: True positive / All positives
    # PPV:         True positive / All predicted
    # F:           2*[(PPV*sensitivity)/(PPV+sensitivity)]
    my $sen = $hash{$pred}{'sensitivity'} = $TP/($TP+$FN);
    my $ppv = $hash{$pred}{'ppv'}         = $TP/($TP+$FP);
    my $f   = $hash{$pred}{'f'}           = 2*($sen*$ppv)/($sen+$ppv);
}

foreach my $pred (sort keys %hash) 
{
    # Stores sensitivity and specificity outside the hash
    my $sensitivity = delete $hash{$pred}{'sensitivity'};
    my $predicted   = delete $hash{$pred}{'predicted'};
    my $ppv         = delete $hash{$pred}{'ppv'};
    my $f           = delete $hash{$pred}{'f'};
    
    # Predictor's name and predicted value
    printf "%-*s   %*s\n", $key_msize, $pred, 
                           $num_msize, $predicted;
    
    foreach my $key (keys %{$hash{$pred}})
    {
        # Prints all the keys in the following format:
        # pred nucleotides = 23.543.354.134
        printf "    %-*s => %*s\n", 11, $key, 
                                    $num_msize, $hash{$pred}{$key};
    }
    
    printf "    %s => %*.7g\n", "PPV        ", $num_msize, 
                                $ppv*100;
    printf "    %s => %*.7g\n", "Sensitivity", $num_msize, 
                                $sensitivity*100;
    printf "    %s => %*.7g\n", "F          ", $num_msize, 
                                $f*100;
    print "//\n"
}
