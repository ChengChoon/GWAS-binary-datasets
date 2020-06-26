


setwd("/home/ang/magna/bam/")

Z = list.files(path = "/home/ang/magna/bam/", pattern ="*.coverage.hist.txt")
             
for (filename in Z) {
  
  cov = read.table(filename)
  
  # extract the genome-wide (i.e., no the per-chromosome)   histogram entries
  
  gcov = cov[cov[,1] == 'genome',]
  
  # plot a density function for the genome-wide coverage
  
  filename_output = paste(substr(filename, 1, nchar(filename)-4), "_histogram.png", sep="")
  
  print(filename)
  
  png(filename_output,width = 6, height = 4,  units = 'in', res = 500)
  plot(gcov[1:501,2], gcov[1:501,5], type='h', col='darkgreen', lwd=3, xlab="Depth", ylab="Fraction of genome at depth",)
  axis(1,at=c(1,50,100,150,200,250,300,350,400,450,500))
  dev.off()
  
  
}

