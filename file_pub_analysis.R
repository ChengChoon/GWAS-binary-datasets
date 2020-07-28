setwd("/home/ang/magna/scicore/vcf/67_samples/c1/SS_no/output/")

source("file_pub.R")

library(ggplot2)

library(cowplot)

gwscan <- read.table("51C_BISNP_filter_exclude_beagle_plink_lmm.assoc.txt",as.is = "rs",header = TRUE)

png("qqplot_51C.png",width = 4, height = 4,  units = 'in', res = 500)

plot.inflation(gwscan$p_lrt)

dev.off()

png("manhanttan_51C.png",width = 11, height = 4,  units = 'in', res = 500)

plot.gwscan(gwscan)

dev.off()
