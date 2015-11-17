#!/bin/bash

Name=$1
binpath=/home/owens/bin/abba_baba
echo "$1"
#Calculate the numerator and denominator for the D-statistic for each loci 
perl $binpath/ABBA_BABA.v2_forind.pl /home/owens/exil/2015/Exil.GATK.2015.tab ${Name}.poplist.txt cennann.calann.bol.per.groups.txt > ${Name}_per_out.txt
#Sum up numerator and denominator for each scaffold and merge together to form blocks
perl $binpath/ABBA_out_blocker.pl ${Name}_per_out.txt > ${Name}_per_out_block.txt
#Jackknife bootstrap through the blocks to get standard error
Rscript $binpath/Jacknife_ABBA_pipe.R ${Name}_per_out_block.txt ${Name}_per_out_jackknife.txt

tail -n 3 ${Name}_per_out.txt > tmp1
tail -n 3 ${Name}_per_out_jackknife.txt > tmp2

paste tmp1 tmp2 > ${Name}_per_out_2.txt
rm tmp1
rm tmp2
Rscript $binpath/ABBA_pvalue.R ${Name}_per_out_2.txt ${Name}_per_out_final.txt
