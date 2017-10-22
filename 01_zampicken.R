
#Environment löschen
rm(list = ls())

#---------------------------------
#Libraries laden
needs(ggplot2)
needs(countrycode)
needs(dplyr)
needs(xlsx)
needs(pwt8)
needs(plotly)
needs(knitr)
needs(kableExtra)
needs(reshape2)
needs(DT)
needs(tidyverse)
needs(rgdal)
needs(leaflet)
needs(googlesheets)
needs(RColorBrewer)
needs(openxlsx)
needs(googlesheets)
needs(data.table)
needs(xlsx)
#---------------------------------


# Datenfileänderungen
# 1979 bis 1990
# 1992 bis 1994
# 1995 bis 2008
# 2009 bis 2012
# ab 31.12. 2012
#

# funktion zum einlesen der daten
readfiles <- function(pfad){
    files <- list.files(pfad)
    file  <- read.csv2(paste(pfad,files[1],sep="/"))
    file$Jahr <- substr(files[1], 20,23)
    
    for (fnames in files[2:length(files)]){
      
      
      dat <- read.csv2(paste(pfad,fnames,sep="/"))
      dat$Jahr <- substr(fnames, 20,23)
      file <- rbind(file, dat)
    }

return(file)
}

# 1979 bis 1990

j79.j90 <- readfiles("./data/BEV - Daten/1979-1990")
saveRDS(j79.j90,"./outputs/1979-1990.rds")


# 1992 bis 1994
j92.j94 <- readfiles("./data/BEV - Daten/1992-1994")
saveRDS(j92.j94,"./outputs/1992-1994.rds")


# 1995 bis 2008
j95.j08 <- readfiles("./data/BEV - Daten/1995-2008")
saveRDS(j95.j08,"./outputs/1995-2008.rds")

# 2009 bis 2012
j09.j12 <- readfiles("./data/BEV - Daten/2009-2012")
saveRDS(j09.j12,"./outputs/2009-2012.rds")


# ab 31.12. 2012

files <- list.files("./data/BEV - Daten/2012-2016")
j12.j16  <- read.csv2(paste("./data/BEV - Daten/2012-2016",files[1],sep="/"))
j12.j16_vw  <- read.csv2(paste("./data/BEV - Daten/2012-2016",files[2],sep="/"))
j12.j16$Jahr <- substr(files[1], 21,24)

colnames(j12.j16)[1] <- "KG.NR"
colnames(j12.j16_vw)[1] <- "KG.NR"

j12.j16 <- left_join(j12.j16,j12.j16_vw)


for (fnames in c(3,5,7,9)){
  
  
  dat <- read.csv2(paste("./data/BEV - Daten/2012-2016",files[fnames],sep="/"))
  dat_vw  <- read.csv2(paste("./data/BEV - Daten/2012-2016",files[fnames+1],sep="/"))
  dat$Jahr <- substr(files[fnames], 21,24)
  colnames(dat)[1] <- "KG.NR"
  colnames(dat_vw)[1] <- "KG.NR"
  dat <- left_join(dat,dat_vw)
  
  j12.j16 <- rbind(j12.j16, dat)
}

saveRDS(j12.j16,"./outputs/2012-2016.rds")


# Datenfileänderungen
# 1979 bis 1990
# 1992 bis 1994
# 1995 bis 2008
# 2009 bis 2012
# ab 31.12. 2012
# http://www.umweltbundesamt.at/umweltsituation/raumordnung/rp_flaecheninanspruchnahme/datenproblematik/


# sum(colnames(j79.j90) %in% colnames(j92.j94))

b79.b94 <- bind_rows(j79.j90,j92.j94)

# ncol(b79.b94)

b79.b08 <- bind_rows(b79.b94,j95.j08)

# sum(colnames(b79.b08) %in% colnames(j09.j12))

b79.b12 <- bind_rows(b79.b08,j09.j12)

# sum(colnames(b79.b12) %in% colnames(j12.j16))


b79.b16 <- bind_rows(b79.b12,j12.j16)


nrow(b79.b16)
ncol(b79.b16)


write.xlsx(colnames(j79.j90),"./outputs/cols_79-90.xlsx")
