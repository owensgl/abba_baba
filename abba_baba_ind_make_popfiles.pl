#!/bin/perl
use warnings;
use strict;

my $popfile = $ARGV[0]; # popfile 
my $groupfile = $ARGV[1]; # group file

my %pophash;
my %grouphash;
my @samplelist;
open POP, $popfile;
while (<POP>){
	chomp;
	my @a = split(/\t/,$_);
	$pophash{$a[0]} = $a[1];
	push(@samplelist, $a[0]);
}
close POP;

open GROUP, $groupfile;
while (<GROUP>){
	chomp;
	my @a = split(/\t/,$_);
	$grouphash{$a[0]} = $a[1];
}

close GROUP;

foreach my $sample (@samplelist){
	my $group = $grouphash{$pophash{$sample}};
	my $outfile;
	if ($group eq "1"){
		$outfile = "${sample}_calann_bol.poplist.txt";
	}elsif ($group eq "2"){
		$outfile = "cenann_${sample}_bol.poplist.txt";
	}elsif ($group eq "3"){
		$outfile = "cenann_calann_${sample}.poplist.txt";
	}else{
		next;
	}
	open OUT, ">", $outfile;
	print OUT "$sample\t$pophash{$sample}";
	foreach my $othersample (@samplelist){
		if ($grouphash{$pophash{$sample}} eq $grouphash{$pophash{$othersample}}){
			next;
		}else{
			print OUT "\n$othersample\t$pophash{$othersample}";
		}
	}
	close OUT;
}
