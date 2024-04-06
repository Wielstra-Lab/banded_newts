#################
### TreeMix.R ###
#################
setwd("E:/Ommatotriton")
getwd()
prefix="Ommatotriton"

library(RColorBrewer)
library(R.utils)
source("plotting_funcs.R") # here you need to add the path

par(mfrow=c(2,3))
for(edge in 0:5){
  plot_tree(cex=0.8,paste0(prefix,".",edge))
  title(paste(edge,"edges"))
}

for(edge in 0:5){
  plot_resid(stem=paste0(prefix,".",edge),pop_order="Adm.list")
