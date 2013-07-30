#!/usr/bin/perl

use strict;
use warnings;

if(scalar @ARGV < 2) {
    die "Usage: perl correct_id.pl pred transcript_name < file.gtf"
}

my $pred = shift @ARGV;
my $i = 1; my $j = 1;

foreach my $file (@ARGV)
{
    print "$file\n";
    open(FILE, "<", $file); $i = 1;
    open(OUT, ">", $file.".new");
    while(my $line = <FILE>)
    {
        if($line =~ m/^\s*$/)
        {
            print OUT $line; 
            $i++; next; 
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
        
        $attribute = "gene_id \"$pred.t$j.g$i\"; "
                   . "transcript_id \"$pred.t$j.g$i\";\n";
        
        print OUT join("\t", $seqname, $source, $feature,
                             $start, $end, $score, 
                             $strand, $frame, $attribute);
    }
    close OUT; close FILE; $j++;
}
