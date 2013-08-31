#!/usr/bin/perl
use v5.10;

#######################################################################
# Program:    find_single_cds.pl                                      #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      This program gets .gtf files and prints the amount of   #
#             single CDS predictions found. The options -a prints     #
#             a relatory with all individual files data together.     #
#             -g creates 2 new files, each one with the single cds    #
#             and all the other predictions.                          #
# date:       08/08/13 (dd/mm/yy)                                     #
#######################################################################

# Pragmas
use strict;
use warnings;
use Getopt::Long;

## HELP/USAGE #########################################################
# Options
Getopt::Long::Configure('bundling');
my $all = undef;
my $gen = undef;

GetOptions(
    'a|all-together'  => \$all,
    'g|generate-file' => \$gen,
);

my $usage_message = << "USAGE_MESSAGE";
    USAGE: perl find_single_cds.pl [-a] [-g] <file1.gtf> ...
USAGE_MESSAGE

if(scalar(@ARGV) <= 0) {
    die "\n$usage_message\n";
}

## GLOBAL VARIABLES ###################################################
my $bad = 0;
my $good = 0;
my $total = 0;
my $all_bad = 0;
my $all_good = 0;
my $all_total = 0;

local $/ = "\n\n";

## SCRIPT #############################################################
FILE: for my $file (@ARGV)
{
    $total = $good = $bad = 0;
    
    # Open file for being read
    open(my $FILE, "<:utf8", $file)
        or die "Problems to open $file: $!";
    
    # Create 2 files: .multiple for good proteins
    # and .single for bad proteins
    my ($GOOD, $BAD) = (undef, undef);
    if($gen) {
        open($GOOD, ">:utf8", "$file.multiple") 
            or die "Problems to open $file.multiple: $!";
        open($BAD,  ">:utf8", "$file.single")
            or die "Problems to open $file.single: $!";
    }
    
    LINE: while(my $line = <$FILE>)
    {
        $total++; $all_total++;
        my @pred = split("\n", $line);
        # say STDERR "DEBUG:SIZE ==> ", scalar @pred;
        
        # Separate singe-cds predictions in the STDERR
        if(scalar @pred <= 3) {
            print $BAD "$line" if $gen;
            $bad++; $all_bad++;
        } else {
            print $GOOD "$line" if $gen;
            $good++; $all_good++;
        }
    }
    
    my $bad_percent = 100 * $bad/$total;
    my $good_percent = 100 * $good/$total;
    
    printf 
    "$file:\n".
    "    Single:   $bad (%2.2f%%)\n".
    "    Multiple: $good (%2.2f%%)\n".
    "    Total:    $total\n".
    "//\n", 
    $bad_percent, $good_percent;
    
    FH: for my $fh ($FILE, $GOOD, $BAD) { 
        close $fh if defined $fh;
    }
}

if($all)
{
    my $bad_percent = 100 * $all_bad/$all_total;
    my $good_percent = 100 * $all_good/$all_total;
    
    printf << "REPORT_ALL", $bad_percent, $good_percent;
all_together:
    Single:   $all_bad (%2.2f%%)
    Multiple: $all_good (%2.2f%%)
    Total:    $all_total
//
REPORT_ALL
}
