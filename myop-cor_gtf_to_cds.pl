#!/usr/bin/perl
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

# Counter for number of chromossomes
# to be corrected
my $WRONGS = 0;

# Get one entire gene
GENE: for my $gene (@{$genes}) 
{
    # Get sequence name
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
                while($start < 0) { $start += 3;} 
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
        qx(transeq /tmp/trans.fa -outseq /tmp/trans.pep 2>/dev/null);
        
        # Read .pep file and get its info
        open(TMP, "<", "/tmp/trans.pep");
        <TMP>; # Take out header
        my $pep = "";
        while(my $line = <TMP>)
        {
            chomp $line;
            $pep .= $line;
        }
        close TMP;
        
        if($pep !~ /\*/)
        {
            # If there is no stop codon in 
            # the middle of the gene, just
            # print it and go to the next
            $gene->output_gtf(\*STDOUT);
            next GENE;
        }
        
        # Count another wrong chrs and
        # store its right part length
        $WRONGS++;
        my $length = 3*length($`);
        
        # Reverse strand
        my @final; 
        if($gene->strand eq "-")
        {
            # Put the start codon in the list of 
            # corrected transcripts
            for my $start (@{$tx->start_codons()})
            {
                push @final, $start;
            }
            
            # Run through the CDS untill achieve the maximum
            # number of nucleotides calculated above
            my $last = 0;
            COR: for my $cds (reverse @{$tx->cds()}) 
            {
                my $size = $cds->length();
                
                # Finishes loop iff pass by a stop codon
                if($last+$size >= $length)
                {
                    $cds->set_start($cds->stop() - ($length-$last-1));
                    $last = $cds->start();
                    push @final, $cds;
                    last COR;
                }
                
                # Otherwise, update counter and prints sequence
                $last += $size;
                push @final, $cds;
            }
            
            # Correct the stop codon
            for my $stop (@{$tx->stop_codons()})
            {
                $stop->set_start  ($last - 3);
                $stop->set_stop   ($last - 1);
                push @final, $stop;
            }
            
            # Print the reverse strand gene
            map { $_->output_gtf(\*STDOUT); } reverse @final;
            print STDOUT "\n";
        }
        # Normal strand
        else 
        {
            # Put the start codon in the list of 
            # corrected transcripts
            for my $start (@{$tx->start_codons()})
            {
                push @final, $start;
            }
            
            # Run through the CDS untill achieve the maximum
            # number of nucleotides calculated above
            my $last = 0;
            COR: for my $cds (@{$tx->cds()}) 
            {
                my $size = $cds->length();
                
                # Finishes loop iff pass by a stop codon
                if($last+$size >= $length)
                {
                    $cds->set_stop($cds->start() + $length-$last-1);
                    $last = $cds->stop();
                    push @final, $cds;
                    last COR;
                }
                
                # Otherwise, update counter and prints sequence
                $last += $size;
                push @final, $cds;
            }
            
            # Correct the stop codon
            for my $stop (@{$tx->stop_codons()})
            {
                $stop->set_start  ($last + 1);
                $stop->set_stop   ($last + 3);
                push @final, $stop;
            }
            
            # Print the normal strand gene
            map { $_->output_gtf(\*STDOUT); } @final;
            print STDOUT "\n";
        }
    }
}

say STDERR "\n=======================================";
say STDERR "NUMBER OF CHROMOSSOMES CORRECTED: $WRONGS";
