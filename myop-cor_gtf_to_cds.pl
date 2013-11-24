#!/usr/bin/perl
package main;
use v5.10;

# Pragmas
use strict;
use warnings;

# Default modules
use GTF;
use Bio::SeqIO;
use File::Copy;
use Data::Dumper;
use Getopt::Long;
use Bio::DB::Fasta;
use Parallel::ForkManager;

# Options
my $gtf_file;
my $fasta;

GetOptions(
    "gtf=s"   => \$gtf_file,
    "fasta=s" => \$fasta
);

# Error treatment
my $witherror = 0;
if(!defined $gtf_file) 
{
    $witherror = 1;
    print STDERR "ERROR: missing gtf file name !\n";
}
if(!defined $fasta) 
{
    $witherror = 1;
    print STDERR "ERROR: missing fasta file name !\n";
}
if($witherror) 
{
    print STDERR "USAGE: $0 -g <gtf file> -f <fasta file>\n";
    exit(-1);
}

# Create gtf file
my $gtf = GTF::new({gtf_filename => $gtf_file,
                    warning_fh => \*STDERR});

my $genes = $gtf->genes;
my $db    = Bio::DB::Fasta->new ("$fasta");
my $seqio = Bio::SeqIO->new ('-format' => 'Fasta', 
                              -fh => \*STDOUT);

# Open corrected with correted predictions
open GTF_COR, ">", "$gtf_file.cor";

my $WRONGS = 0;

# Get one entire gene
GENE: for my $gene (@{$genes}) 
{
    my $source = $gene->seqname();
    
    # Get one transcript of the gene
    TRANS: for my $tx (@{$gene->transcripts()}) 
    {
        # Get one CDS
        my $seq = "";
        CDS: for my $cds (@{$tx->cds()}) 
        {
            my $start  = $cds->start();
            my $stop = $cds->stop();
            
            if($start < 0) 
            {
                while($start <0) { $start += 3;} 
            }
            
            # Get sequence from the database
            my $x = $db->seq("$source:$start,$stop");
            if(!defined ($x) ) 
            { 
                print STDERR "ERROR: something wrong with ",
                             "sequence $source:$start,$stop\n";
                exit(-1);
            }
            $seq .= $x;
        }
        
        # Reverse strand
        if ($gene->strand eq "-") 
        {
            my $seqobj = Bio::PrimarySeq->new(
                -seq => $seq, -alphabet =>'dna', -id => "XX"
            );
            $seqobj = $seqobj->revcom();
            $seq = $seqobj->seq();
        }
        
        # Create .fa from the above transcripts
        open(TMP, ">", "/tmp/trans.fa");
        say TMP $seq;
        close TMP;
        
        # Pass transeq over .fa
        qx(transeq /tmp/trans.fa -outseq /tmp/trans.pep 
            2>/dev/null);
        
        open(TMP, "<", "/tmp/trans.pep");
        <TMP>; # Take out header
        my $pep = "";
        while(my $line = <TMP>)
        {
            chomp $line;
            $pep .= $line;
        }
        close TMP;
        
        say STDERR "\n==:> ORIGINAL GTF";
        say STDERR $pep;
        
        my $length = 0;
        if($pep =~ /\*/)
        {
            say STDERR "\n==:> NEEDS CORRECTION";
            say STDERR "PEP_COR: ", substr($pep, 0, length $`);
            say STDERR "length:  ", length($`);
            say STDERR "SEQ_COR: ", substr($seq, 0, 3 * length($`));
            say STDERR "length:  ", 3*length($`);
            
            $seq = substr($seq, 0, 3 * length($`));
            $length = 3*length($`);
            $WRONGS++;
        }
        else { $gene->output_gtf(\*GTF_COR); }
        
        # Output sequence untill first *
        my $seqobj = Bio::PrimarySeq->new(
            -seq => $seq, -alphabet =>'dna', -id => $tx->id()
        );
        
        $seqio->write_seq($seqobj);
        
        # No *, do nothing else
        next GENE if($pep !~ /\*/);
        
        # Make corrections on each gene
        say STDERR "\n==:> CORRECTING";
        
        # Reverse strand
        if($gene->strand eq "-") 
        {
            my $size = 0; my $last = 0; my @final;
            COR: for my $cds (reverse @{$tx->cds()}) 
            {
                my $size = $cds->length();
                say STDERR "-------------";
                say STDERR "CDS size: ", $size;
                
                # Finishes loop iff pass by a stop codon
                if($last+$size >= $length)
                {
                    say STDERR "[1]: LAST:      ", $last;
                    say STDERR "[2]: LENGTH:    ", $length;
                    say STDERR "[3]: [2]-[1]-1: ", $length-$last-1;
                    say STDERR "$size";
                    
                    say STDERR "LENGTH-LAST-1: ", $length-$last-1;
                    say STDERR "LENGTH-LAST-1: ", $cds->start() +$length-$last-1;
                    say STDERR "CDS END:     ", $cds->stop();
                    $cds->set_start($cds->stop() - ($length-$last-1));
                    $cds->output_gtf(\*STDERR);
                    # $cds->output_gtf(\*GTF_COR);
                    
                    $last = $cds->start();
                    
                    unshift @final, $cds;
                    last COR;
                }
                
                # Otherwise, update counter and prints sequence
                $last += $size;
                say STDERR "Count   : ", $last;
                $cds->output_gtf(\*STDERR);
                # $cds->output_gtf(\*GTF_COR);
                unshift @final, $cds;
            }
            say STDERR "Last: ", $last;
            
            for my $stop (@{$tx->stop_codons()})
            {
                $stop->set_start  ($last - 3);
                $stop->set_stop   ($last - 1);
                $stop->output_gtf(\*STDERR);
                unshift @final, $stop;
                # $stop->output_gtf(\*GTF_COR);
            }
            
            for my $start (@{$tx->start_codons()})
            {
                # $start->set_start  ($last-2);
                # $start->set_stop   ($last);
                # $start->output_gtf (\*GTF_COR);
                # $start->output_gtf (\*STDERR);
                push @final, $start;
            }
            
            say STDERR "=======================";
            map { $_->output_gtf(\*STDERR); $_->output_gtf(\*GTF_COR); } @final;
            print GTF_COR "\n";
        }
        # Normal strand
        else 
        {
            for my $start (@{$tx->start_codons()})
            {
                $start->output_gtf(\*STDERR);
                $start->output_gtf(\*GTF_COR);
            }
            
            my $size = 0; my $last = 0;
            COR: for my $cds (@{$tx->cds()}) 
            {
                my $size = $cds->length();
                say STDERR "-------------";
                say STDERR "CDS size: ", $size;
                
                # Finishes loop iff pass by a stop codon
                if($last+$size >= $length)
                {
                    say STDERR "[1]: LAST:      ", $last;
                    say STDERR "[2]: LENGTH:    ", $length;
                    say STDERR "[3]: [2]-[1]-1: ", $length-$last-1;
                    say STDERR "$size";
                    
                    say STDERR "LENGTH-LAST-1: ", $length-$last-1;
                    say STDERR "LENGTH-LAST-1: ", $cds->start() +$length-$last-1;
                    say STDERR "CDS END:       ", $cds->stop();
                    $cds->set_stop($cds->start() + $length-$last-1);
                    $cds->output_gtf(\*STDERR);
                    $cds->output_gtf(\*GTF_COR);
                    
                    $last = $cds->stop();
                    last COR;
                }
                
                # Otherwise, update counter and prints sequence
                $last += $size;
                say STDERR "Count   : ", $last;
                $cds->output_gtf(\*STDERR);
                $cds->output_gtf(\*GTF_COR);
            }
            say STDERR "Last: ", $last;
            
            for my $stop (@{$tx->stop_codons()})
            {
                $stop->set_start  ($last + 1);
                $stop->set_stop   ($last + 3);
                $stop->output_gtf (\*GTF_COR);
                $stop->output_gtf (\*STDERR);
                print GTF_COR "\n";
            }
        }
        say STDERR "GENE START:  ", $gene->start();
        say STDERR "GENE STOP:   ", $gene->stop();
        say STDERR "GENE LENGTH: ", $gene->length();
    }
}

# Close gtf file with all info
close GTF_COR;

say STDERR $WRONGS;
