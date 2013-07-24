#!/usr/bin/perl

use strict;
use warnings;

sub start {
    my $mask = shift;
    (my $start, my $end) = split('-', $mask);
    return $start;
}

sub end{
    my $mask = shift;
    (my $start, my $end) = split('-', $mask);
    return $end;
}

sub comeco{
    my $gene = shift;
    my @lines = split("\n", $gene);
    
    (my $seqname, 
     my $source, 
     my $feature, 
     my $comeco, 
     my $fim, 
     my $score, 
     my $strand, 
     my $frame, 
     my $attribute) = split("\t",$lines[0]);
    print STDERR "DEBUG:=============gene=========\n=>$gene\n----------\n===>start=$comeco\n================\n";
    return $comeco;
}

sub fim {
    my $gene = shift @_;
    my @lines = split("\n", $gene);
    (my $seqname, 
     my $source, 
     my $feature, 
     my $comeco, 
     my $fim, 
     my $score, 
     my $strand, 
     my $frame, 
     my $attribute) = split("\t",$lines[$#lines]);
    print STDERR "DEBUG:=============gene=========\n=>$gene\n----------\n===>end=$fim\n================\n";

    return $fim;
}

sub main()  {   
    if(scalar(@ARGV) != 3) {
        die "Usage: remove_mapped.pl <predictor> <.gtf> <.map>";
    }
    my $predictor = shift @ARGV;
    my $gene_file = shift @ARGV;
    my $mask_file = shift @ARGV;
    
    my $myop_delim = "\n\n";
    my $augustus_delim = "\n###\n";
    
    my @genes; 
    my @maskings;
    
    #
    # first we need the correct read delimiter
    #
    my $old_delim = $/;
    if ($predictor =~ m/myop/i){
        $/ = $myop_delim;
    }
    elsif ($predictor =~ m/augustus/i){
        $/ = $augustus_delim;
    }
    else {
        die "gene predictor name not recognized (should be 'augustus' or 'myop'):$predictor\n";
    }
    
    # Cria listas com os nomes
    open(GENE, "<", $gene_file);
    while(my $one_gene = <GENE>) {
        chomp($one_gene);
        #remove commens and blank lines
        if ($one_gene !~ m/\#/){
            #print STDERR "DEBUG:==============pushing+++++++++\n=>$one_gene<=\n================\n";
            push(@genes,$one_gene);
        }
        else {
            if (($predictor =~ "augustus") && ($one_gene =~m/\#\s*start\s+gene/)){
                my @lines = split("\n", $one_gene);
                my @new_lines= ();
                foreach my $one_line (@lines){
                    if ($one_line !~ m/\s*\#/ 
                    and $one_line !~ m/^(\s|\t)*$/) {
                        push(@new_lines, $one_line);
                    }
                }
                $one_gene = join("\n",@new_lines);
                push(@genes,$one_gene);
            }
            else {
                print STDERR "DEBUG:==============ignoring==>$one_gene<=\nn================\n";
            }
        }
    }
    close(GENE);
    
    $/=$old_delim;
    open(MASK, "<", $mask_file);
    <MASK>;
    while(my $one_masking = <MASK>) { 
        push (@maskings, $one_masking); 
    }
    close(MASK);

    @maskings = sort { start($a) <=> start($b) } @maskings;
    @genes = sort { comeco($a) <=> comeco($b) } @genes;
    
    my $next_gene = shift(@genes);
    my $next_mask = shift(@maskings);
    my $gene_count = 1;    
    my $mask_count = 1;
    my $loop_count = 0;
    my $good_gene_count = 0;
    
    SEARCHLOOP:
    while(1){
        $loop_count++;
        if(end($next_mask) < comeco($next_gene)) {
            if (scalar(@maskings) == 0) {
                print STDERR "UMA VEZ !!!!\n" ;
                print "$next_gene\n\n";
                $good_gene_count++;
                foreach $next_gene (@genes){
                    $good_gene_count++;
                    print "$next_gene\n\n";
                }
                last SEARCHLOOP;
            } 
            else {
                $next_mask = shift(@maskings);
                $mask_count++;
            }
        } 
        elsif (fim($next_gene) < start($next_mask)) {
            print "$next_gene\n\n"; # "Não está em região mascarada";
            $good_gene_count ++;
            if (scalar(@genes) == 0 ){
                last SEARCHLOOP;
            } 
            else {
                $next_gene = shift(@genes);
                $gene_count++;
            }
        }
        else{
            print STDERR "DEBUG:==>mask:$next_mask, eliminates:\n$next_gene----------------\n";
            # Tem intersecção, descarta o gene
            if (scalar(@genes) == 0 ){
                last SEARCHLOOP;
            } 
            else {
                $next_gene = shift(@genes);
                $gene_count++;
            }
        } # fim
    } # laço
    print STDERR "DEBUG:====>$gene_count genes, $mask_count maskings processed, 
          $loop_count interactions, $good_gene_count genes selected\n";
} # main
main();
