setwd("/home/ang/magna/scicore/vcf/")

INFO73C <- read.csv("/home/ang/magna/scicore/vcf/73C_SNP_filter_exclude_nohead.vcf.gz_forplot.txt", sep="")

INFO73C$AC = as.numeric(INFO73C$AC)
INFO73C$AF = as.numeric(INFO73C$AF)
INFO73C$MLEAC = as.numeric(INFO73C$MLEAC)
INFO73C$MLEAF = as.numeric(INFO73C$MLEAF)
library(lattice)

png("INFO73C$QD.png",width = 8, height = 4,  units = 'in', res = 500)
densityplot(INFO73C$QD)
dev.off()

png("INFO73C$FS.png",width = 8, height = 4,  units = 'in', res = 500)
densityplot(INFO73C$FS)
dev.off()

png("INFO73C$SOR.png",width = 8, height = 4,  units = 'in', res = 500)
densityplot(INFO73C$SOR)
dev.off()

png("INFO73C$MQD.png",width = 8, height = 4,  units = 'in', res = 500)
densityplot(INFO73C$MQ)
dev.off()

png("INFO73C$MQRankSum.png",width = 8, height = 4,  units = 'in', res = 500)
densityplot(INFO73C$MQRankSum)
dev.off()

png("INFO73C$ReadPosRankSu.png",width = 8, height = 4,  units = 'in', res = 500)
densityplot(INFO73C$ReadPosRankSum)
dev.off()

png("INFO73C$DP.png",width = 8, height = 4,  units = 'in', res = 500)
densityplot(INFO73C$DP)
dev.off()
