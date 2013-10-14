#!/usr/bin/perl
use v5.10;

use strict;
use warnings;

my $prediction = shift @ARGV;
my $genome     = shift @ARGV;

say STDERR "PREDICTION ==:> $prediction";
say STDERR "GENOME     ==:> $genome";

my %pred; # Hash with begginings and ends

# Get starts and ends of the predictions
open(PREDIC, "<", $prediction) or die "Could not open $prediction";
local $/ = "\n\n";
while(my $pred = <PREDIC>)
{
    chomp $pred;
    my @field = split /\n/, $pred;
    
    # Takes firs and last codon:
    (my $f_seqname, 
     my $f_source, 
     my $f_feature, 
     my $f_start, 
     my $f_end, 
     my $f_score, 
     my $f_strand, 
     my $f_frame, 
     my $f_attribute) = split("\t",$field[0]);
    
    (my $l_seqname, 
     my $l_source, 
     my $l_feature, 
     my $l_start, 
     my $l_end, 
     my $l_score, 
     my $l_strand, 
     my $l_frame, 
     my $l_attribute) = split("\t",$field[-1]);
    
    $pred{$f_start} = $l_end;
}
close PREDIC;
local $/ = "\n";

# Print genomes correspondents
open(GENOME, "<", $genome) or die "Could not open $genome";
my $header = <GENOME>; # Discard header

# Crete an array with the begginings
my @start = sort { $a <=> $b } keys %pred;
my $count = 0; my $began = 0;

my $i = 0; my $seq; my $n = 1;
while(my $line = <GENOME>)
{
    chomp $line;
    my $updated = $count + length $line;
    # say STDERR $n++;

    # If there is no start here and no sequence
    # begun, so there is nothing to do with this line...
    if($start[0] > $updated and !$began)
    { $count = $updated; next; }

    # But if a sequence is here, then we should
    # try to find its end (and print while it):
    if($start[0] <= $updated)
    {
        $began = 1 if($pred{$start[0]} > $updated);
    }
    
    if($pred{$start[0]} > $updated)
    {
        # If the i-th end is not inside this line, 2 possibilities:
        # * Either we began here, and the sequence is a substring
        #   from the start to the end of the line;
        # * Or we began in other line, and the entire line should
        #   be printed.
        ($began) 
            ? ($seq .= $line) 
            : ($seq .= substr $line, $start[0]-$count)
        ;
        $seq .= "\n";
    }
    else #if($pred{$start[0]} <= $updated)
    {
        # If there is an end here, so there is 2 possibilities:
        # * Either we began here, and the sequence is a substring;
        # * Or we began in other line, and then, our sequence comes
        #   from 0 untill the end's position.
        my $size = $pred{$start[0]}-$count;
        ($began)
            ? ($seq .= substr $line, 0, $size)
            : ($seq .= substr $line, $start[0]-$count, $size)
        ;
        $seq .= "\n";
        # say STDERR $start[0], "=>", $pred{$start[0]};
        print "> ", "myop.g1.t", ++$i, "\n";
        print "$seq\n"; 
        
        # Dealing with aternative splicing
        my $old = shift @start;
        # if(defined $start[0] and $pred{$old} == $pred{$start[0]})
        if(defined $start[0] and $start[0] <= $pred{$old})
        {
            print "> ", "myop.g1.t", ++$i, "\n";
            # say substr $seq, $pred{$start[0]}-$pred{$old};
            say substr $seq, $start[0]-$old;
            my $old = shift @start;
        }
        else { $began = 0; $seq = ""; }
        
        # last if(scalar @start == 0);
        if(scalar @start == 0) { last; }
        
        # The last case is: there is still a begin here, after
        # the end of the last prediction: Let's redo all the 
        # work, without updating the line, but looking for the
        # beggining of the new sequence.
        redo if($start[0] <= $updated);
    }
    
    # All done? Let's go the next line!
    $count = $updated; 
}

close GENOME;
