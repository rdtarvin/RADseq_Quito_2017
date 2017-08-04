library("ape")
library("pegas")
library("seqinr")
library("ggplot2")
library("adegenet")
library("hierfstat")



myFile <- import2genind("Pr-03-22-6c.stru") ##XXX SNPs and XX inds

##QUESTIONS:
### Which column contains the population factor ('0' if absent)? 
###answer:2
###Which other optional columns should be read (press 'return' when done)? 
###Which row contains the marker names ('0' if absent)? 
###Answer:1

myFile


########################

X <- scaleGen(myFile, NA.method="mean")
X[1:5,1:5]



pca1<-dudi.pca(X,cent=FALSE,scale=FALSE,scannf=FALSE,nf=3)


############################################
#####   to find names of outliers    #######
############################################
s.label(pca1$li)




################################################
###  NEIGHBOR-JOINING TREE COMPARED TO PCA   ###
################################################
library(ape)
tre<-nj(dist(as.matrix(X)))
tre
plot(tre,typ="fan",cex=0.7)


myCol<-colorplot(pca1$li,pca1$li,transp=TRUE,cex=4)
abline(h=0,v=0,col="grey")


plot(tre,typ="fan",show.tip=FALSE)
tiplabels(pch=20,col=myCol,cex=2)




########################################################
###  DISCRIMINANT ANALYSIS OF PRINCIPAL COMPONENTS   ###
########################################################
grp<-find.clusters(X,max.n.clust=5)
###keep 20 PCs
###keep 3 clusters (original pops)
names(grp)
grp$size
table(pop(myFile),grp$grp)
dapc1<-dapc(X,grp$grp)
dapc1
scatter(dapc1)
summary(dapc1)
set.seed=(4)
contrib<-loadingplot(dapc1$var.contr,axis=2,thres=.07,lab.jitter=1)
####################################
#####   DAPC by original pops   ####
####################################


dapc2<-dapc(X,pop(myFile))
dapc2
scatter(dapc2)
summary(dapc2)
contrib<-loadingplot(dapc2$var.contr,axis=2,thres=.07,lab.jitter=1)

####################################################
###   plotting DAPCs with ggplot and ellipses    ###
####################################################
plot_dapc<-as.data.frame(dapc2$ind.coord)
plot_dapc$group=pop(myFile)

ggplot(plot_dapc,aes(x=LD1,y=LD2,col=group))+geom_point()+
stat_ellipse()+theme_bw()+xlab("LD1")+scale_colour_manual(values=c("grey", "red","pink", "darkgreen", "lightgreen", "royalblue4", "lightblue"))
eig<-data.frame(eigs=dapc2$eig,LDs=1:6)
ggplot(eig,aes(x=LDs,y=eigs))+geom_bar(stat='identity')+
theme_bw()



####################
###  COMPOPLOT   ###
####################

compoplot(dapc2,posi="bottomright",lab="",
			ncol=1,xlab="individuals")


###################################################
###     DIVERSITY AND POPULATION MEASURES       ###
###################################################

library(hierfstat)
####load dataset with struture-informed populations
myFile2 <- import2genind("Xr-03-22-2c-b.stru") ##1118 SNPs and 91 inds (After oulier removed)

basicstat<-basic.stats(myFile, diploid=TRUE)
basicstat
Hobs<-basicstat$Ho
Hobs
write(Hobs, file="Xr-Hobs-03-22.txt", ncol=7)

Hexp<-basicstat$Hs
Hexp
write(Hexp, file="Xr-Hexp-03-22.txt", ncol=7)

Fis<-basicstat$Fis
Fis
write(Fis, file="Xr-Fis-03-22.txt", ncol=7)

bartlett.test(list(basicstat$Hs, basicstat $Ho)) ##this gives you a statistical
##measure of whether observed and expected heterozygosity are different


library(diveRsity)
divBasic(infile="Xr-03-22-2c-b.genepop.txt", outfile="Xr-03-22-diversity", gp=2, bootstraps=NULL, HWEexact=FALSE)

##########################################
###  PAIRWISE Fst WITH BOOTSTRAPPING   ###
##########################################

pairwise.fst(myFile)
##replicate(10,pairwise.fst(myFile,pop=sample(pop(myFile))))
##nuc.div(myFile2)

##t.test(myFile$Hexp,myFile$Hobs,pair=T,var.equal=TRUE,alter="greater")




###################################################
###               STRATAG PACKAGE               ###
###################################################
library(strataG)
##transform file from genind to gtypes
myFile3<-genind2gtypes(myFile2)

myFile3 ##summaries of heterozygosity per population/strata

##snp.summary<-summary(myFile3)
##snp.summary
##str(snp.summary)

##summarizeLoci(myFile3)

###population structure###
##statFst(myFile3)
##statGst(myFile3, nrep=10, keep.null=TRUE)


##nucleotideDiversity(myFile3)


##strata.schemes
##myFile3




###################################################
###               popGENOME PACKAGE               ###
###################################################

##library(PopGenome)





