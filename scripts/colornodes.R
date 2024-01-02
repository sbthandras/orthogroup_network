library(tidyverse)

network<-read.csv("results/vcontact2_blastp/c1.ntw",sep=" ",header=F)
# Get all type of nodes

strnodes<-data.frame(node=unique(union(network$V1,network$V2)))
strnodes$accession<-sub("_[^_]+$", "",strnodes$node)


# Importing taxids
therapy<-read.csv("input/usable_rows.txt",header=FALSE)
lytic<-read.csv("input/lytic_phages.txt",header=FALSE)

nodes<-strnodes

nodes$in_lab<-"no"
nodes$therapy<-"no"

# Renaming NAs
nodes[is.na(nodes)] <- "not_found"
therapynames<-read.table("input/therapy_keywords.txt",header=F,sep="\t")

ictv <- readxl::read_excel("./input/VMR_20-190822_MSL37.2.xlsx",)
ourphages <- readxl::read_excel("./input/Phage_isolatetes_Kintses_lab.xlsx",)
ourphages<-as.data.frame(ourphages)
ictv<-as.data.frame(ictv)
ictv$gbfile<-ictv$`Virus GENBANK accession`
ictv$name<-ictv$`Virus name(s)`
ictv<-dplyr::filter(ictv,Class=="Caudoviricetes"&!grepl(",",`Virus GENBANK accession`))
ictv$accession<-ictv$`Virus GENBANK accession`


ournodes<-dplyr::filter(nodes,grepl("vB",accession))
nodes<-dplyr::filter(nodes,!grepl("vB",accession))


nodes<-merge(x=nodes,y=ictv[,c("accession","name","Subgenus","Genus","Subfamily","Family","Order")],by="accession",all.x=TRUE)
ournodes<-merge(x=ournodes,y=ourphages[,c("node","Subgenus","Genus","Subfamily","Family","Order")],by="node",all.x=TRUE)
ournodes$name<-""

nodes<-rbind(nodes,ournodes)


for(i in seq_along(nodes$node)){
  if(nodes$accession[i] %in% therapy$V1) (nodes$therapy[i]<-"yes")
  
  if(grepl("vB",nodes$node[i])){
    #nodes[,c("accession","name","Subgenus","Genus","Subfamily","Family","Order")][i,]<-"in_lab"
    nodes$in_lab[i]<-"yes"
    nodes$name[i]<-paste0("Acinetobacter phage ",gsub(".*vB","vB",nodes$node[i]))
  } 
  # if(grepl("phage|virus ",nodes$name[i],ignore.case=T)&!grepl("phage|virus ",nodes$name[i],ignore.case=T)){
  #   if(!grepl("vB",nodes$node[i])) nodes$name[i]<-paste0(nodes$name[i]," ",nodes$name[i])
  # }  
  
}
nodes$lytic=""
for(i in seq_along(nodes$node)){
  for(trp in therapynames$V1){
    if(grepl(trp,nodes$name[i])) (nodes$therapy[i]<-"yes")
  }
  for(trp in therapy$V1){
    if(grepl(trp,nodes$node[i])) (nodes$therapy[i]<-"yes")
  }
  for(lyt in lytic$V1){
    if(grepl(lyt,nodes$node[i])){
      nodes$lytic[i]<-"yes"
      nodes$therapy[i]<-""
    } 
  }

}

nodes$name<-gsub("^B_[A-Z][A-Z][A-Z][A-Z]","",nodes$name,ignore.case = T)
nodes$name<-gsub("_"," ",nodes$name,ignore.case = T)

save(nodes,file=paste0("results/nodes.rda"))
write.table(nodes,file="results/nodes.csv",sep=",",row.names=F)
