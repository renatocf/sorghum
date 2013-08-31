#!/usr/bin/perl
package main;
use v5.10;

#######################################################################
# Program:    create_map.pl                                           #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets a .fa/.fasta file masked from input   # 
#             with 'X' and outputs a 'map' file which can be used to  #
#             verify the existence of predictions inside the masked   #
#             fasta.                                                  #
# date:       12/04/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;
use Getopt::Long;
    
## HELP/USAGE #########################################################
my $usage_message = << "USAGE"
    USAGE: create_map.pl [-h] < fasta_file > map_file
    Type --help for further information.
USAGE

my $help_message = << "HELP"
    create_map by Renato Cordeiro Ferreira
    
    This program gets a .fa/.fasta file masked with 'X' and
    creates a '.map' file (own format) which can be used to
    verify the existence of predictions inside the masked 
    regions.
    
    * file.map
    -----------------------------
    The output file has as name 'file.map'. Each header in the
    fasta is counted and printed in the output. Besides this, 
    each line represents a masked region, in the format BN-EN
    (begin_nucleotide-end_nucleotide)
    
    USAGE: create_mask_map.pl [-h] <fasta_file>
HELP

# Options
Getopt::Long::Configure('bundling');
my $help = '';
GetOptions('h|help' => \$help);

# Help/Usage
if($help) {
    die "\n$help_message\n";
} elsif (scalar(@ARGV) != 0) {
    die "\n$usage_message\n";
}

## GLOBAL VARIABLES ###################################################
local $/ = ">";    # Text separator

## SCRIPT #############################################################
my $seq = <STDIN>; # Takes out the first line

LINE: while($seq = <>)
{
    # Variables for the text 
    my $real_seq = '';
    my $header = '';
    
    # Variables for positions  
    my $position = 0; 
    my $start = 0; 
    my $size = 0;
    
    # Split multiple lines in an array and take
    # out the first (which is part of a header).
    my @linhas = split("\n", $seq);
    $header = shift @linhas;
    
    # Prints header and sequence
    print ">";
    print "$header" if(defined($header)); 
    print "\n";
    
    # If the last element is '>', take it out
    next LINE unless(scalar(@linhas) != 0);
    pop @linhas if($linhas[-1] =~ m/\>.*/);
    
    # Create variable with the content of the lines
    $real_seq = join("", @linhas);
    
    # Seraches by masked 'X' (5 at least) and prints
    # a map with the positions of the masked sequences
    MASK: while($real_seq =~ m/XXXXX+/)
    {
        # Position of the beginning of the sequence 
        # and its size:
        $start = length($`); $size = length($&);
        
        # Create maps to the masked sequences:    
        print $start + $position + 1, "-"; 
        print $start + $position + $size, "\n";
        
        # Exchange variables to the nex iteration
        $real_seq = $'; $position += $start + $size;
    }
}
