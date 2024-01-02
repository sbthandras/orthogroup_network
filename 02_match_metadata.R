ictv <- readxl::read_excel("./input/VMR_20-190822_MSL37.2.xlsx",)
ictv$gbfile<-ictv["Virus GENBANK accession"]
ictv<-dplyr::filter(ictv,Class=="Caudoviricetes"&!grepl(",",`Virus GENBANK accession`))
ntw<-read.table("results/vcontact2_blastp/c1.ntw",sep="",header=F)
names(ntw)<-c("source","target","weight")
metadata<-data.frame(unique(union(ntw$source,ntw$target)))

names(metadata)<-c("node")
metadata$accession<-gsub("\\_.*","",metadata$node)

# First try matching by accession
# then try matching by virus name
names(ictv)
ictv$accession<-ictv["Virus GENBANK accession"]

metadata<-merge(x=metadata,y=ictv[,c("accession","Species","Subgenus","Genus","Subfamily","Family","Order")],by="accession",all.x=TRUE)
