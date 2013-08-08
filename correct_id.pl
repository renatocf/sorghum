#!/usr/bin/perl
use v5.10;

#######################################################################
# Program:    correct_id;pl                                           #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets a .gtf file and change its gene and   #
#             transcript ids to avoid problems with them. Useful      #
#             when you pass any script that returns not all the .gtf  #
#             lines (and which create gaps in the numbering).         #
# date:       08/08/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;

# Usage
if(scalar @ARGV < 2) {
    die "Usage: perl correct_id.pl pred transcript_name < file.gtf"
}

## GLOBAL VARIABLES ###################################################
my $pred = shift @ARGV;
my $i = 1; my $j = 1;

## SCRIPTS ############################################################
FILES: for my $file (@ARGV)
{
    # Print the file being processed.
    # Each line receives an unique id with $i
    print "$file\n"; $i = 1;
    
    # Open file for reading and new one to write
    open(FILE, "<", $file); 
    open(OUT, ">", $file.".new");
    
    LINES: while(my $line = <FILE>)
    {
        if($line =~ m/^\s*$/)
        {
            print OUT $line; 
            $i++; next LINES; 
        } 
        
        # Split .gtf line in its fields
        (my $seqname, 
         my $source, 
         my $feature, 
         my $start, 
         my $end, 
         my $score, 
         my $strand, 
         my $frame, 
         my $attribute) = split("\t",$line);
        
        # Rewrite attribute field with the new numbers
        $attribute = "gene_id \"$pred.t$j.g$i\"; "
                   . "transcript_id \"$pred.t$j.g$i\";\n";
        
        # Print in the output the new version
        print OUT join("\t", $seqname, $source, $feature,
                             $start, $end, $score, 
                             $strand, $frame, $attribute);
    }
    # Close files. Each file will receive a special 
    # sequential id represented bt the $j variable
    close OUT; close FILE; $j++;
}
