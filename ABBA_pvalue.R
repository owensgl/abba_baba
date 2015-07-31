#This script takes the final output from the ABBA_BABA pipeline and puts zscores and pvalues on the final results
inputfile <- commandArgs(trailingOnly = TRUE)

tmp <- read.table(inputfile[1], header=F)
Zscore <- tmp[,3]/tmp[,4]
Pvalue <- 2*pnorm(-abs(Zscore))
total <- cbind(tmp, Zscore,Pvalue)

write.table(total, file=inputfile[2], quote=F, sep="\t", row.names=F, col.names=F)