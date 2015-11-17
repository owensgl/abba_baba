#!/bin/perl
use warnings;
use strict;

my $list = $ARGV[0];

open LIST, $list;

my @samplelist;
while(<LIST>){
	chomp;
	push(@samplelist, $_);
}
print "pop1\tpop2\tpop3\tpop4\tpermuted_group\tD_score\tD_std\tD_zscore\tD_pvalue\tFhom_score\tFhom_std\tFhom_zscore\tFhom_pvalue\tFd_score\tFd_std\tFd_zscore\tFd_pvalue\tn_sites";
foreach my $sample (@samplelist){
	my @pops = split(/_/,$sample);
	print "\n$pops[0]\t$pops[1]\t$pops[2]\t$pops[3]";
	my $permuted_group;
	if ($pops[0] ne "cenann"){
		$permuted_group = 1;
	}elsif ($pops[1] ne "calann"){
		$permuted_group = 2;
	}else{
		$permuted_group = 3;
	}
	print "\t$permuted_group";
	open IN, "${sample}_out_final.txt";
	while(<IN>){
		chomp;
		my $line = $_;
		my @tmp = split(/\t/,$line);
		print "\t$tmp[2]\t$tmp[3]\t$tmp[4]\t$tmp[5]";
	}
	close IN;
	my $lines;
	open (FILE, "<", "${sample}_out.txt") or die "Can't open file";
	$lines++ while (<FILE>);
	close FILE;
#	$lines;
	print "\t$lines";
}
