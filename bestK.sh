
for Kvalue in {1..4}; do
for Try in {1..10}; do grep -h "^Loglikelihood:" log.K$Kvalue.RUN$Try.out; done  > LL.K$Kvalue.txt;
done



grep -h CV log*out > CV.txt


###plot the distribution of values associated to each K in R.


read.table("CV.txt")->cv  

# set which one was the smallest and the largest K that you ran
minK<-2
maxK<-10

ordine<-c()
for (k in minK:maxK){
  ordine[k]<-paste("(K=",k,"):",sep="", collapse = "")
}

ordine <- ordine[!is.na(ordine)]

library(ggplot2)

p <- ggplot(cv, aes(x=V3, y=V4)) + 
  geom_boxplot()+ 
  ggtitle("values associated to each K")+
  scale_x_discrete(limits=ordine)
  
p


#####

MYINFO<-read.table("infoAdmixtureExercis.txt", header=T, as.is=T)


table(MYINFO$population)->pops
namespop<-unique(MYINFO$population)

my.labels <- vector()   ## plotting pop labels instead of sample ids
for (k in 1:length(namespop)){
  paste("^",namespop[k],"$",sep="")->a
  length(grep(a, MYINFO$population)) -> my.labels[k]
}

labels.coords<-vector()  ### where to plot pop labels
labels.coords[1]<-my.labels[1]/2
for (i in 1:(length(my.labels)-1)) {
  labels.coords[i]+(my.labels[i]/2+my.labels[i+1]/2)->labels.coords[i+1]
}
z<-vector()
z[1]<-my.labels[1]
for (i in 1:(length(my.labels)-1)){
  z[i]+my.labels[i+1]->z[i+1]
}

# select a color palette
# you can use colorbrewer. put together a number of colours equal Kmax.

library(RColorBrewer)
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
colorchoice<-sample(col_vector, maxK)
#pie(rep(1,maxK), col=coso)

# now plot for each K
K<-2 # chose the K to plot. Start with the lowest.

valuesToplot<-read.table(paste("K",K,".Run1.Q", sep="", collapse = ""))

valuesToplotSort<-valuesToplot[MYINFO$oderAdmix,]

#pdf(paste("AdmixtureForK",K,".pdf", sep="", collapse = ""),pointsize=8, height=3.5)

barplot(t(as.matrix(valuesToplotSort)), col=colorchoice[1:K], axisnames=F, axes=F, space=0,border=NA)
axis(3, labels = FALSE, tick=F)
for (i in c(0,z)){
  lines(x=c(i,i),y=c(0,3), lwd=0.7, col="white")
}
text(labels.coords, par("usr")[3] + 1.03 , srt = 45, adj = 0, labels = namespop, cex=0.7, xpd = TRUE)
#dev.off()


