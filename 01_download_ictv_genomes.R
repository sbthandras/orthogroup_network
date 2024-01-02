ictv <- readxl::read_excel("./input/VMR_20-190822_MSL37.2.xlsx",)
ictv$gbfile<-ictv["Virus GENBANK accession"]
ictv<-dplyr::filter(ictv,Class=="Caudoviricetes"&!grepl(",",`Virus GENBANK accession`))
system("mkdir genomedir")
system("cp labdata/* input/")
for(i in ictv$`Virus GENBANK accession`){
  accession=i
  print(i)
  destfile <- paste0("genomedir/", accession,".gb")
  if (file.exists(destfile)) next
  cmd <- paste0(
    "efetch -db nuccore -id ",
    accession,
    " -format gb > ",
    destfile)
  if (!file.exists(destfile)) {
    print(paste0("Downloading ", accession))
    system(cmd)
  }
}

## Download therapeutic phages
therapeutic<-read.table("input/usable_rows.txt")
for(i in therapeutic$V1){
  accession=i
  print(i)
  destfile <- paste0("genomedir/", accession,".gb")
  if (file.exists(destfile)) next
  cmd <- paste0(
    "efetch -db nuccore -id ",
    accession,
    " -format gb > ",
    destfile)
  if (!file.exists(destfile)) {
    print(paste0("Downloading ", accession))
    system(cmd)
  }
}

