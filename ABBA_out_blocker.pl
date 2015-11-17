#!/usr/bin/perl

use warnings;
use strict;
#This takes in the ABBA BABA output, sums all applicable values within a scaffold


my $in = $ARGV[0]; #The output of ABBA_BABA.pl with 3



my $DNum = 0;
my $DDenom = 0;
my $FhomNum = 0;
my $FhomDenom = 0;
my $FdDenom = 0;
my $FdNum = 0;
my $current_chr;
my $window_size = 10000000;
my $current_end = $window_size;
my %colname;
my $counter = 0;
open IN, $in;
while (<IN>){
	chomp;
	my @a = split (/\t/, $_);
	if ($. == 1){
		foreach my $i (0..$#a){
			$colname{$i}= $a[$i];
		}
		print "chr\twindow_start\twindow_mid\twindow_end\tn_sites\tDNum\tDDenom\tD\tFhomNum\tFhomDenom\tFhom\tFdNum\tFdDenom\tFd\n";
	}else{
		unless($#a eq 0){
			unless ($current_chr){
				$current_chr = $a[0];
			}
			if (($current_chr ne $a[0]) or ($current_end < $a[1])){
				my $D;
				if ($DDenom ne "0"){
					$D = ($DNum / $DDenom);
				}else{
					$D = 0;
				}
				my $Fd;
				my $Fhom;
				if ($FdDenom ne "0"){
					$Fd = ($FdNum / $FdDenom);
				}else{
					$Fd = 0;
				}
				if ($FhomDenom ne "0"){
					$Fhom = ($FhomNum / $FhomDenom);
				}else{
					$Fhom = "0";
				}
				my $current_start = $current_end - $window_size;
				my $current_mid = $current_end - ($window_size/2);
				print "$current_chr\t$current_start\t$current_mid\t$current_end\t$counter\t$DNum\t$DDenom\t$D\t$FhomNum\t$FhomDenom\t$Fhom\t$FdNum\t$FdDenom\t$Fd\n";
				$DDenom = 0;
				$DNum = 0;
				$FdNum = 0;
				$FdDenom = 0;
				$FhomNum = 0;
				$FhomDenom = 0;
				$counter = 0;
				if ($current_chr ne $a[0]){
					$current_chr = $a[0];
					$current_end = $window_size;
				}
				until($current_end > $a[1]){
					$current_end+= $window_size;
				}
			}
			$counter++;	
			foreach my $i (0..$#a){
				if ($colname{$i} eq "DDenom"){
					$DDenom += $a[$i];
#					print "Has DDenom\t$a[$i]\n";
				}elsif ($colname{$i} eq "DNum"){
					$DNum += $a[$i];
 #                                      print "Has DNum\t$a[$i]\n";
				}elsif ($colname{$i} eq "FdNum"){
	                     	        $FdNum += $a[$i];
#                                       print "Has FdNum\t$a[$i]\n";
				}elsif ($colname{$i} eq "FdDenom"){
                                        $FdDenom += $a[$i];
#                                       print "Has FdDeno\t$a[$i]\n";
				}elsif ($colname{$i} eq "FhomNum"){
                                        $FhomNum += $a[$i];
#                                       print "Has FhomNum\t$a[$i]\n";
				}elsif ($colname{$i} eq "FhomDenom"){
#                                                print "Has FhomDenom\t$a[$i]\n";
                                        $FhomDenom += $a[$i];
				}
                        }
		}
	}
}
			
	
