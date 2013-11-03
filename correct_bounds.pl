#!/usr/bin/perl
use v5.10;
my $DEBUG = 0;

use strict;
use warnings;

my $pred  = shift @ARGV;
my $short = shift @ARGV;

my $USAGE = "perl correct_bounds.pl myop.gtf myop.pred.short";

my %myop_pred;
my %myop_pep;

open PRED , "<", $pred or die $USAGE;
local $/ = "\n\n";
while(my $line = <PRED>)
{
    chomp $line;
    my @line = split "\n", $line;
    
    (my $seqname, 
     my $source, 
     my $feature, 
     my $start, 
     my $end, 
     my $score, 
     my $strand, 
     my $frame, 
     my $attribute) = split("\t",$line[0]);
     
    my @attr = split /\s+/, $attribute;
    $attr[1] =~ m/myop\.t\d+\.g(\d+)/;
    my $gene_id = $1;
    
    $myop_pred{$gene_id} = \@line;
}
close PRED;

# for my $key (sort { $a <=> $b } keys %myop_pred)
# {
#     say "==== $key =========================";
#     say @{$myop_pred{$key}}, "\n";
# }

open SHORT, "<", $short;
local $/ = ">";
<SHORT>;
while(my $line = <SHORT>)
{
    chomp $line;
    
    # Get line and separate it
    my @line = split /\n/, $line;
    my @header = split /\s+/, $line[0];
    
    # Get group gene id's
    $header[0] =~ m/myop\.t\d+\.g(\d+)/;
    my $gene_id = $1;
    
    # Stores peptides in a hash by gene_id
    $myop_pep{$gene_id} = $line[1];
}
close SHORT;

# for my $key (sort { $a <=> $b } keys %myop_pep)
# {
#     say "==== $key =========================";
#     say $myop_pep{$key}, "\n";
# }

for my $key (sort { $a <=> $b } keys %myop_pep)
{
    say "==== genome_id $key =========================";
    say $myop_pep{$key}, "\n";
    
    $myop_pep{$key} =~ m/(.*)\*/;
    my $good_gene = $1;
    say "== WITHOUT STOP (", length $good_gene, ") ========";
    say $good_gene, "\n";
    
    # Size in nucleotides
    my $good_gene_length = 3 * (length $good_gene);
    
    # Useful variables for correcting loop
    my @corrected; my $remaining;
    
    # Copies array and discard start_codon
    push @corrected, shift @{$myop_pred{$key}};
    
    say "==== IDs =========================";
    my $total = 0; # Accumulated nucleotides
    for my $pred (@{$myop_pred{$key}})
    {
        (my $seqname, 
         my $source, 
         my $feature, 
         my $start, 
         my $end, 
         my $score, 
         my $strand, 
         my $frame, 
         my $attribute) = split("\t",$pred);
        
        $total += ($end - $start);
        if($total <= $good_gene_length)
        {
            # say $pred;
            # say $total, " < ", $good_gene_length;
            $remaining = $good_gene_length - $total;
            # say "Remains: $remaining";
            push @corrected, $pred;
        }
        else
        {
            # Corrects last prediction boundary
            #say $pred;
            my $new_end = $start + $remaining;
            #say $new_end;
            $pred = join("\t", $seqname, $source, $feature,
                               $start, $new_end, $score, 
                               $strand, $frame, $attribute);
            #say "CORRECTED: $pred";
            push @corrected, $pred;
            
            # Corrects stop codon
            my $last = $#{$myop_pred{$key}};
            $pred = $myop_pred{$key}->[$last];
            
            (my $seqname, 
             my $source, 
             my $feature, 
             my $start, 
             my $end, 
             my $score, 
             my $strand, 
             my $frame, 
             my $attribute) = split("\t",$pred);
            
            $pred = join("\t", $seqname, $source, $feature,
                               $new_end+1, $new_end+3, $score, 
                               $strand, $frame, $attribute);
            push @corrected, $pred;
            # map { say } @corrected; print "\n";
            
            last;
        }
    }
    map { say } @corrected; 
    $myop_pred{$key} = \@corrected;
    
    print "\n";
}

# Create corrected file
say "$pred.cor";

open PRED_COR, ">", "$pred.cor";
select PRED_COR;
for my $key (sort { $a <=> $b } keys %myop_pred)
{
    # say "==== $key =========================";
    map { say } @{$myop_pred{$key}}; print "\n";
}
select STDOUT;
close PRED_COR;
