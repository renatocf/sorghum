#!/usr/bin/perl

use warnings;
use strict;
use bigint;

if(scalar(@ARGV) != 3) {
    die "Usage: change_prefix.pl <predictor> <.gtf> <quantity>";
}

my $predictor = shift @ARGV;
my $gene_file = shift @ARGV;
my $quantity = shift @ARGV;

my $myop_delim = "\n\n";
my $pasa_delim = "\n\n";
my $augustus_delim = "\n###\n";

#
# first we need the correct read delimiter
#
my $old_delim = $/;
if ($predictor =~ m/myop/i){
    $/ = $myop_delim;
}
elsif ($predictor =~ m/pasa/i){
    $/ = $pasa_delim;
}
elsif ($predictor =~ m/augustus/i){
    $/ = $augustus_delim;
}
else {
    die "gene predictor name not recognized (should be 'augustus' or 'myop'):$predictor\n";
}

open(GENE, "<", $gene_file);
while(my $gene = <GENE>) {
    chomp;
    
    my @lines = split("\n", $gene);
    foreach my $line (@lines) {
        if($line =~ m/^\s*\#/) { 
            next; 
        }
        elsif($line =~ m/^\s*$/) {
            print "$line\n";
            next;
        }
        
        (my $seqname, 
         my $source, 
         my $feature, 
         my $start, 
         my $end, 
         my $score, 
         my $strand, 
         my $frame, 
         my $attribute) = split("\t",$line);
        
        print STDERR "DEBUG======>old:$start";
        $start += $quantity;
        print STDERR " new: $start<======\n";
        print STDERR "DEBUG======>old:$end";
        $end += $quantity;
        print STDERR " new: $end<======\n";
        $line = join("\t", $seqname, $source, $feature, $start,
            $end, $score, $strand, $frame, $attribute);
        print "$line\n";
    }
    print "\n";
}
close(GENE);

# print STDERR "DEBUG:=============gene=========\n=>$gene\n----------\n===>start=$comeco\n================\n";
# return $comeco;
