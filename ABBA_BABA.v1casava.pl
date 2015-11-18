#!/usr/bin/perl


#Sept 2014. Updated to make denominator and numerator sum for each loci and then average
use warnings;
use strict;
my %t;
$t{"N"} = "NN";
$t{"A"} = "AA";
$t{"T"} = "TT";
$t{"G"} = "GG";
$t{"C"} = "CC";
$t{"W"} = "TA";
$t{"R"} = "AG";
$t{"M"} = "AC";
$t{"S"} = "CG";
$t{"K"} = "TG";
$t{"Y"} = "CT";

my $in = $ARGV[0]; #In SNP table in iupac or not. Will detect the number of columns before data
my $pop = $ARGV[1]; #Population file, (samplename\tpopname\n)
my $poporder = $ARGV[2]; #The file specify which populations represent which samples in the ABBA BABA scheme (popname\t[1-4]\n)

my $badcolumns = 5;
my $iupac = "False";
my %pop;
my %poplist;
my %group;
my %samplegroup;
my @Dvalues;
my @Fhomvalues;
my @Fdvalues;
my $totalDenom;
my $totalNum;
my $Samples;
my $fhomNum;
my $fhomDenom;
my $fdNum;
my $fdDenom;
#Load population information
open POP, $pop;
while (<POP>){
	chomp;
	my @a = split (/\t/,$_);	
	$pop{$a[0]}=$a[1];
	$poplist{$a[1]}++;
}
close POP;
#Load group information
open GROUP, $poporder;
while (<GROUP>){
	chomp;
	my @a = split (/\t/,$_);
	$group{$a[0]} = $a[1];
}
close GROUP;

open IN, $in;
while (<IN>){
	chomp;
	next if /^\s*$/;
	my @a = split (/\t/,$_);
  	if ($. == 1){
  		foreach my $i ($badcolumns..$#a){ #Get sample names for each column
        		if ($pop{$a[$i]}){
				if ($group{$pop{$a[$i]}}){
	        			$samplegroup{$i} = $group{$pop{$a[$i]}};
				}
        		}
        	}
        	print "CHR\tPOS\tP1\tQ1\tn1\tP2\tQ2\tn2\tP3\tQ3\tn3\tP4\tQ4\tn4\tABBA\tBABA\tDNum\tDDenom\tFhomNum\tFhomDenom\tFdNum\tFdDenom\n";
	}else{
   		my $pos = "$a[0]\t$a[1]";
    		my %BC;
		my %total_alleles;
		#Load in data for each individual and sum up allele frequencies by group 
    		foreach my $i ($badcolumns..$#a){
			if ($samplegroup{$i}){
				$BC{"total"}{"total"}++;
				unless ($a[$i] eq "N"){
					my @bases = split(/\//, $a[$i]);
					unless($bases[1]){
						$bases[1] = $bases[0];
					}
					$total_alleles{$bases[0]}++;
					$total_alleles{$bases[1]}++;
					
					$BC{"total"}{$bases[0]}++;
		        		$BC{"total"}{$bases[1]}++;
					$BC{$samplegroup{$i}}{$bases[0]}++;
		 			$BC{$samplegroup{$i}}{$bases[1]}++;	

					$BC{"total"}{"Calls"}++;
					$BC{$samplegroup{$i}}{"Calls"}++;
				}
			}
		}

		my %B;
		my %A;
		my $missing;
		
		if (keys %total_alleles == 2){ #Only look at biallelic sites
			my @bases = sort { $total_alleles{$b} <=> $total_alleles{$a} } keys %total_alleles ;
			my @outgroupbases = sort { $BC{4}{$b} <=> $BC{4}{$a} } keys %{$BC{4}}; #Sort bases in outgroup
			if ($outgroupbases[0]){
				my $A = $outgroupbases[0]; #Ancestral allele (A)
				my $B;
				if ($bases[0] eq $outgroupbases[0]){
					$B = $bases[1]; #Derived allele (B)
				}else{
					$B = $bases[0]; #Derived allele (B)
				}
				foreach my $i(1..4){
					if ($BC{$i}{"Calls"}){
						if ($BC{$i}{$B}){
							$B{$i} = $BC{$i}{$B}/($BC{$i}{"Calls"} * 2);
							$A{$i} = (1 - $B{$i});
						}else{
							$B{$i} = 0;
							$A{$i} = 1;
						}
					}else{
						$B{$i} = "NA";
						$A{$i} = "NA";
						$missing++;
					}
				}
                                if ($B{4} ne "0"){
                                	$missing++;
                                }
				unless ($missing){
					my $ABBA = ($A{"1"} * $B{"2"} * $B{"3"} * $A{"4"});
					my $BABA = ($B{"1"} * $A{"2"} * $B{"3"} * $A{"4"});
					my $BABA1330 = ($B{"1"} * $A{"3"} * $B{"3"} * $A{"4"});
					my $ABBA1330 = ($A{"1"} * $B{"3"} * $B{"3"} * $A{"4"});
					my $BABA1220 = ($B{"1"} * $A{"2"} * $B{"2"} * $A{"4"});
					my $ABBA1220 = ($A{"1"} * $B{"2"} * $B{"2"} * $A{"4"});				
					unless (($ABBA eq 0) and ($BABA eq 0)){
						my $DNum = ($ABBA - $BABA);
						my $DDenom = ($ABBA + $BABA); 
						$totalDenom += ($ABBA + $BABA);
						$totalNum += ($ABBA - $BABA);
						$Samples++;
						my $S1 = ($ABBA - $BABA);
						my $S2 = ($ABBA1330 - $BABA1330);
						my $S3;
						if ($B{"3"} >= $B{"2"}){
							$S3 = ($ABBA1330 - $BABA1330);
						}elsif ($B{"3"} <= $B{"2"}){
							$S3 = ($ABBA1220 - $BABA1220)
						}
						$fhomNum += $S1;
						$fhomDenom += $S2;
						$fdNum += $S1;
						$fdDenom += $S3;
						print "$pos";
						foreach my $i (1..4){
							print "\t$B{$i}\t$A{$i}\t$BC{$i}{'Calls'}||";
						}
						print "\t$ABBA\t$BABA\t$DNum\t$DDenom\t$S1\t$S2\t$S1\t$S3";
						print "\n";
					}
					
				}
			}
		}
	}
}
close IN; 

########
my $averageD = ($totalNum / $totalDenom);

######
my $averageFhom = ($fhomNum / $fhomDenom);

#####
my $averageFd = ($fdNum / $fdDenom);
######
print "AverageD = $averageD\n";
print "AverageFhom = $averageFhom\n";
print "AverageFd = $averageFd\n";



