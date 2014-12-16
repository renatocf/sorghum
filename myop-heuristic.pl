#!/usr/bin/perl
use v5.10;

#######################################################################
# Program:    myop-heuristic.pl                                       #
# mantainer:  Renato Cordeiro Ferreira                                #
# usage:      Runs over a .gtf file generated by MYOP looking for     #
#             chromossomes with stop codons in their middle. When     #
#             founded, find the biggest part of the prediction and    #
#             correct it to be treated as the biggest prediction.     #
# date:       09/01/14 (dd/mm/yy)                                     #
#######################################################################

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

sub cmp_gene
{
    my $a = shift;
    my $b = shift;
    my $na = $a->id(); $na =~ s/myop\.t[0-9]\.g//;
    my $nb = $b->id(); $nb =~ s/myop\.t[0-9]\.g//;
    return $na <=> $nb;
}

# Get one entire gene
GENE: for my $gene (sort { &cmp_gene($a,$b) } @{$genes}) 
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
        
        if($pep !~ /(.*)\*(.*)/)
        {
            # If there is no stop codon in 
            # the middle of the gene, just
            # print it and go to the next
            $gene->output_gtf(\*STDOUT);
            next GENE;
        }
        else { say STDERR $gene->id() }
        
        # Count another wrong chrs and
        # store its right part length
        $WRONGS++;
        my ($lseq,$rseq) = ($1,$2); 
        
        say STDERR $pep;
        my $err_length = 0;
        if($rseq =~ /(.*?)M(.*)/)
        {
            $err_length = 3*(length($1)+1);
            say STDERR "BEFORE M: ", $1;
            say STDERR 3*(length($1)+1);
            say STDERR "AFTER  M: ", $2;
        }
        
        my $length  = 3*length($lseq);
        my $llength = 3*length($lseq);
        my $rlength = 3*length($rseq) - $err_length;
        
        say STDERR "llength: $llength rlength: $rlength";
        
        # Keep left if it is bigger then the right possible script
        my $keep_left = ($llength > $rlength);
        
        # No error length means no start codon after bad stop codon.
        # Therefore, it may be no protein in the left
        $keep_left = 1 if $err_length == 0;
        # DEBUG: my $keep_left = 0;
        
        # Reverse strand
        my (@l_final, @r_final); 
        if($gene->strand eq "-")
        {
            # Run through the CDS untill achieve the maximum
            # number of nucleotides calculated above
            my $last = 0; my $after_value = 0;
            COR: for my $cds (reverse @{$tx->cds()})
            {
                my $size = $cds->length();
                
                # Remove nucleotides after the stop codon
                if($keep_left)
                {
                    # DEBUG: say STDERR "=============> KEEP LEFT";
                    # Finishes loop iff pass by a stop codon
                    if($last+$size >= $length and $keep_left)
                    {
                        $cds->set_start($cds->stop() - ($length-$last-1));
                        $last = $cds->start();
                        push @l_final, $cds;
                        last COR;
                    }
                    
                    # Otherwise, update counter and prints sequence
                    $last += $size;
                    push @l_final, $cds;
                }
                # Remove nucleotides before the stop codon
                else 
                {
                    # DEBUG: say STDERR "=============> KEEP RIGHT";
                    if($last+$size >= $length+$err_length)
                    {
                        unless($after_value)
                        {
                            $after_value = 1;
                            $last = $cds->stop() - ($length+$err_length-$last);
                            $cds->set_stop($last);
                        }
                        
                        # DEBUG: say STDERR "RSIZE > length+err_length";
                        push @l_final, $cds;
                    }
                    else { say STDERR ($last += $size); }
                }
            }
            
            #
            #                          .-- length+err_length
            #   1375   new start       |        104 
            # 1375-1373   ^                     103-101
            #   .---------:----------------------.
            #   |   |     :                      |   | 
            #   '---------:----------------------'
            # cds-stop  * M
            #       ^-- last
            
            # Correct the start codon
            for my $start (reverse @{$tx->start_codons()})
            {
                if(not $keep_left)
                { 
                    $start->set_start ($last - 2);
                    $start->set_stop  ($last);
                }
                unshift @l_final, $start;
            }
            
            # Correct the stop codon
            for my $stop (@{$tx->stop_codons()})
            {
                if($keep_left)
                { 
                    $stop->set_start  ($last - 3);
                    $stop->set_stop   ($last - 1);
                }
                push @l_final, $stop;
            }
                    
            # Correct frames
            for(my $i = 1; $i < scalar @l_final; $i++)
            {
                my $length = $l_final[$i-1]->length();
                my $frame  = $l_final[$i-1]->frame();
                my $new_frame = (3 - (($length-$frame) % 3)) % 3;
                $l_final[$i]->set_frame($new_frame);
            }
            
            # Print the reverse strand gene
            map { $_->output_gtf(\*STDOUT); } reverse @l_final;
            print STDOUT "\n";
        }
        # Normal strand
        else 
        {
            # Run through the CDS untill achieve the maximum
            # number of nucleotides calculated above
            my $last = 0; my $after_value = 0;
            COR: for my $cds (@{$tx->cds()}) 
            {
                my $size = $cds->length();
                
                # Remove nucleotides after stop codon
                if($keep_left)
                {
                    # Finishes loop iff pass by a stop codon
                    if($last+$size >= $length)
                    {
                        $cds->set_stop($cds->start() + $length-$last-1);
                        $last = $cds->stop();
                        push @l_final, $cds;
                        last COR;
                    }
                    
                    # Otherwise, update counter and prints sequence
                    $last += $size;
                    push @l_final, $cds;
                }
                # Remove nucleotides before stop codon
                else
                {
                    # DEBUG: say STDERR "=============> KEEP RIGHT";
                    if($last+$size >= $length+$err_length)
                    {
                        unless($after_value)
                        {
                            $after_value = 1;
                            $last = $cds->start() + ($length+$err_length-$last);
                            $cds->set_start($last);
                        }
                        
                        # DEBUG: say STDERR "RSIZE > length+err_length";
                        push @l_final, $cds;
                    }
                    else { say STDERR "Last: ", ($last += $size); }
                }
            }
            
            #
            #                          .-- length+err_length
            #   1375   new start       |        104 
            # 8534-8336   ^                     103-101
            #   .---------:----------------------.
            #   |   |     :                      |   | 
            #   '---------:----------------------'
            # cds-start * M
            #       ^-- last
            
            # Correct the start codons
            for my $start (reverse @{$tx->start_codons()})
            {
                unless($keep_left)
                { 
                    my $first_start = $l_final[0]->start();
                    $start->set_start ($first_start);
                    $start->set_stop  ($first_start+2);
                }
                unshift @l_final, $start;
            }
            
            # Correct the stop codons
            for my $stop (@{$tx->stop_codons()})
            {
                if($keep_left)
                { 
                    my $last_stop = $l_final[$#l_final]->stop();
                    $stop->set_start  ($last + 1);
                    $stop->set_stop   ($last + 3);
                }
                push @l_final, $stop;
            }
                    
            # Correct frames
            for(my $i = 1; $i < scalar @l_final; $i++)
            {
                my $length = $l_final[$i-1]->length();
                my $frame  = $l_final[$i-1]->frame();
                my $new_frame = (3 - (($length-$frame) % 3)) % 3;
                $l_final[$i]->set_frame($new_frame);
            }
            
            # Print the normal strand gene
            map { $_->output_gtf(\*STDOUT); } @l_final;
            print STDOUT "\n";
        }
    }
}

say STDERR "\n=======================================";
say STDERR "NUMBER OF CHROMOSSOMES CORRECTED: $WRONGS";
