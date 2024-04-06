###Script written by Peter Scott UCLA

#set working directory
setwd("E:/Ommatotriton/PCA")

getwd()

install.packages("ggplot2")

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager:::install("gdsfmt")
BiocManager:::install("SNPRelate")
library("tidyverse")
library("ggplot2")
library("rlang")

library(gdsfmt)
library(SNPRelate)
library(ggplot2)
library(RColorBrewer)
library(cowplot)
library(ggrepel)
library(wesanderson)

vcf_ERC_Comb_rawgvcf <- "E:/Ommatotriton/PCA/Ommatotriton.g.vcf"

snpgdsVCF2GDS(vcf_ERC_Comb_rawgvcf, "E:/Ommatotriton/PCA/Ommatotritonvcf.gds", method="biallelic.only")

snpgdsSummary("E:/Ommatotriton/PCA/Ommatotritonvcf.gds")

vcf_ERC_Comb_allrawgvcf_gds<- snpgdsOpen("E:/Ommatotriton/PCA/Ommatotritonvcf.gds")

###new try phylogeny
set.seed(100)

par(mar=c(4,1,1,1))
par("mar")

#dissimilarity matrix
trial_dissim <- snpgdsHCluster(snpgdsIBS(vcf_ERC_Comb_allrawgvcf_gds,num.thread=2,autosome.onl=FALSE))
#maketree
cut_tree <- snpgdsCutTree(trial_dissim)
cut_tree
#save dendogram
dendogram = cut_tree$dendrogram

dendogram

snpgdsDrawTree(cut_tree,clust.count=NULL,dend.idx=NULL,
               type=c("dendrogram", "z-score"), yaxis.height=TRUE, yaxis.kinship=TRUE,
               y.kinship.baseline=NaN, y.label.kinship=FALSE, outlier.n=NULL,
               shadow.col=c(rgb(0.5, 0.5, 0.5, 0.25), rgb(0.5, 0.5, 0.5, 0.05)),
               outlier.col=rgb(1, 0.50, 0.50, 0.5), leaflab="perpendicular",
               labels=NULL, y.label=0.2)
plot(cut_tree$dendogram,horiz=T,main="trial dendogram SNP Tree")

###PCA
pca_vcf_ERC_Comb_allrawgvcf <- snpgdsPCA(vcf_ERC_Comb_allrawgvcf_gds, autosome.only = FALSE)
pca_vcf_ERC_Comb_allrawgvcf
pc.percent <- pca_vcf_ERC_Comb_allrawgvcf$varprop*100
(round(pc.percent, 2))

tab <- data.frame(sample.id = pca_vcf_ERC_Comb_allrawgvcf$sample.id,
                  EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                  EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                  stringsAsFactors = FALSE)
head(tab)

vcf_ERC_Comb_allrawgvcf_names<-read.csv("E:/Ommatotriton/PCA/List.txt",sep="\t")
head(vcf_ERC_Comb_allrawgvcf_names)

#par(mar=c(1,1,1,1))
#par(oma=c(0,0,0,0))

##plot PCA with no colors
plot(tab$EV2, tab$EV1, xlab="eigenvector 2", ylab="eigenvector 1")

####This is for Ben's PC1-2 and PC1-3 plots with 4 or 8 colors

pop=vcf_ERC_Comb_allrawgvcf_names$pop.code
sp=vcf_ERC_Comb_allrawgvcf_names$sp.code
cat=vcf_ERC_Comb_allrawgvcf_names$cat.code


### ALL RAW POP COLUMN TABS ###
### COUNTRIES

tab1 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$sample.number,
                    EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                    EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                    key = pop)

#write.table(tab12, file="Tab12_sampleID.txt", sep="\t")

tab2 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$sample.number,
                    EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                    EV3 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,3], # the second eigenvector
                    stringsAsFactors = FALSE)

#write.table(tab13, file="Tab13_sampleID.txt", sep="\t")

tab3 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$sample.number,
                    EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                    EV3 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,3],
                    stringsAsFactors = FALSE)

#write.table(tab23, file="Tab23_sampleID.txt", sep="\t")

#Choose: 1st = all labels, 2nd is only a few/not too much overlapping
options(ggrepel.max.overlaps = Inf)
#options(ggrepel.max.overlaps = 10)

sp.colors3<-c("lightgreen","blue","hotpink")
sp.colors19<-c("lightpink1", "cornsilk3", "cyan2","lightgreen", "hotpink", "firebrick4", "darkblue", "forestgreen", "tomato3", "wheat1", "tan", "cornflowerblue", "coral3", "chocolate2", "yellow2", "chartreuse1", "cadetblue4", "grey64", "burlywood")

gplot1 <- ggplot(tab1, aes(EV1,EV2,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors3) + 
  #geom_text(aes(label=vcf_ERC_Comb_testallrawgvcf_names$pop.code), size=3) +
  geom_text_repel(aes(x = EV1, y = EV2, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC1 (22.08%)") +
  ylab("PC2 (8.33%)") +
  theme_bw() 

gplot2 <- ggplot(tab2, aes(EV1,EV3,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors3) +
  geom_text_repel(aes(x = EV1, y = EV3, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC1 (22.08%)") +
  ylab("PC3 (6.62%)") +
  theme_bw() 

gplot3 <- ggplot(tab3, aes(EV2,EV3,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors3) +
  geom_text_repel(aes(x = EV2, y = EV3, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC2 (8.33%)") +
  ylab("PC3 (6.62%)") +
  theme_bw()

gplot1
gplot2
gplot3


### ALL RAW POP COLUMN TABS ###
### LOCALITIES

tab12 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Genus = vcf_ERC_Comb_allrawgvcf_names$pop.code,
                    EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                    EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                    key = pop)

#write.table(tab12, file="Tab12_sampleID.txt", sep="\t")

tab13 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$pop.code,
                    EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                    EV3 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,3], # the second eigenvector
                    stringsAsFactors = FALSE)

#write.table(tab13, file="Tab13_sampleID.txt", sep="\t")

tab23 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$pop.code,
                    EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                    EV3 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,3],
                    stringsAsFactors = FALSE)

#write.table(tab23, file="Tab23_sampleID.txt", sep="\t")

#Choose: 1st = all labels, 2nd is only a few/not too much overlapping
options(ggrepel.max.overlaps = Inf)
#options(ggrepel.max.overlaps = 10)

sp.colors4<-c("aquamarine1", "brown2", "darkorchid1", "cornflowerblue")

sp.colors25<-c("lightpink1", "cornsilk3", "cyan2","lightgreen", "hotpink", "firebrick4", "darkblue", "forestgreen", "tomato3", "wheat1", "tan", "cornflowerblue", "coral3", "chocolate2", "chartreuse4", "chartreuse1", "cadetblue4", "cadetblue1", "burlywood", "brown2", "blueviolet", "blue2", "black", "aquamarine3", "dodgerblue4", "navy", "aquamarine1", "mediumblue")

gplot12 <- ggplot(tab12, aes(EV1,EV2,color=Genus)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors25) + 
  #geom_text(aes(label=vcf_ERC_Comb_testallrawgvcf_names$pop.code), size=3) +
  geom_text_repel(aes(x = EV1, y = EV2, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC1 (22.08%)") +
  ylab("PC2 (8.33%)") +
  theme_bw() 

gplot13 <- ggplot(tab13, aes(EV1,EV3,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors25) +
  geom_text_repel(aes(x = EV1, y = EV3, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC1 (22.08%)") +
  ylab("PC3 (6.62%)") +
  theme_bw() 

gplot23 <- ggplot(tab23, aes(EV2,EV3,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors25) +
  geom_text_repel(aes(x = EV2, y = EV3, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC2 (8.33%)") +
  ylab("PC3 (6.62%)") +
  theme_bw()

gplot12
gplot13
gplot23



### ALL RAW SP - SPECIES ONLY  - COLUMN TABS ###
### CLADE LABELS



tab122 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Island = vcf_ERC_Comb_allrawgvcf_names$sp.code,
                    EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                    EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                    key = pop)

tab133 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$sp.code,
                    EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                    EV3 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,3], # the second eigenvector
                    stringsAsFactors = FALSE)

tab233 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$sp.code,
                    EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                    EV3 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,3],
                    stringsAsFactors = FALSE)

#Choose: 1st = all labels, 2nd is only a few/not too much overlapping
options(ggrepel.max.overlaps = Inf)
#options(ggrepel.max.overlaps = 10)

sp.colors6<-c("cyan", "red3", "blue2", "orange", "chocolate3", "yellow1")

gplot122 <- ggplot(tab122, aes(EV1,EV2,color=Island)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors6) + 
  #geom_text(aes(label=vcf_ERC_Comb_testallrawgvcf_names$sp.code), size=3) +
  geom_text_repel(aes(x = EV1, y = EV2, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC1 (22.08%)") +
  ylab("PC2 (8.33%)") +
  theme_bw() 

gplot133 <- ggplot(tab133, aes(EV1,EV3,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors6) +
  geom_text_repel(aes(x = EV1, y = EV3, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC1 (22.08%)") +
  ylab("PC3 (6.62%)") +
  theme_bw() 

gplot233 <- ggplot(tab233, aes(EV2,EV3,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors6) +
  geom_text_repel(aes(x = EV2, y = EV3, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC2 (8.33%)") +
  ylab("PC3 (6.62%)") +
  theme_bw()

gplot122
gplot133
gplot233



### ALL RAW CAT - CATEGORY/GENOTYPE - COLUMN TABS ###



tab12 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$cat.code,
                    EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                    EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                    key = pop)

tab13 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$cat.code,
                    EV1 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,1], # the first eigenvector
                    EV3 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,3], # the second eigenvector
                    stringsAsFactors = FALSE)

tab23 <- data.frame(sample.id = vcf_ERC_Comb_allrawgvcf_names$sample.id,
                    Species = vcf_ERC_Comb_allrawgvcf_names$cat.code,
                    EV2 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,2], # the second eigenvector
                    EV3 = pca_vcf_ERC_Comb_allrawgvcf$eigenvect[,3],
                    stringsAsFactors = FALSE)

#Choose: 1st = all labels, 2nd is only a few/not too much overlapping
options(ggrepel.max.overlaps = Inf)
options(ggrepel.max.overlaps = 10)

gplot12 <- ggplot(tab12, aes(EV1,EV2,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors25) + 
  #geom_text(aes(label=vcf_ERC_Comb_allrawgvcf_names$sp.code), size=3) +
  geom_text_repel(aes(x = EV1, y = EV2, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC1 (22.08%)") +
  ylab("PC2 (8.33%)") +
  theme_bw() 

gplot13 <- ggplot(tab13, aes(EV1,EV3,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors25) + 
  #geom_text(aes(label=vcf_ERC_Comb_allrawgvcf_names$sp.code), size=3) +
  geom_text_repel(aes(x = EV1, y = EV3, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC1 (22.08%)") +
  ylab("PC3 (8.33%)") +
  theme_bw() 

gplot23 <- ggplot(tab23, aes(EV2,EV3,color=Species)) + geom_point(size=3) +
  scale_color_manual(values = sp.colors25) + 
  #geom_text(aes(label=vcf_ERC_Comb_allrawgvcf_names$sp.code), size=3) +
  geom_text_repel(aes(x = EV2, y = EV3, label = vcf_ERC_Comb_allrawgvcf_names$sample.id)) +
  xlab("PC2 (22.08%)") +
  ylab("PC3 (8.33%)") +
  theme_bw() 

gplot12
gplot13
gplot23
