#!/bin/bash
#To run use gnu parallel. Example usage:
#cat comparisonlist.txt | parallel -j 2 bash ./ABBA_BABA_pipe_casava.sh
#comparisonlist.txt is a list of comparisons you want to do, that already have groupfiles (e.g. par.tst.lrlac.wilds)
name=$1 #
binpath= #Enter the path to the abba_baba scripts here.
snpfile= #Enter full path to the tab separated SNP file here.
popfile= #Enter full path to the population file here.
echo "$1"

#Calculate the numerator and denominator for the D-statistic for each loci 
perl $binpath/ABBA_BABA.v1casava.pl $snpfile $popfile ${Name}.groups.txt > ${Name}_out.txt
#Sum up numerator and denominator for each scaffold and merge together to form blocks
perl $binpath/ABBA_out_blocker.pl ${Name}_out.txt > ${Name}_out_block.txt
#Jackknife bootstrap through the blocks to get standard error
Rscript $binpath/Jacknife_ABBA_pipe.R ${Name}_out_block.txt ${Name}_out_jackknife.txt

tail -n 3 ${Name}_out.txt > tmp1
tail -n 3 ${Name}_out_jackknife.txt > tmp2

paste tmp1 tmp2 > ${Name}_out_2.txt
rm tmp1
rm tmp2
Rscript $binpath/ABBA_pvalue.R ${Name}_out_2.txt ${Name}_out_final.txt
