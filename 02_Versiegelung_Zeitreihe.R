
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

#################
# 2012-2016
#################

j2012.2016 <- readRDS("./outputs/2012-2016.rds")

j2012.2016[is.na(j2012.2016)] <- 0


#Gewichtung der Flächen lt. Email von Hrn. Banko
j2012.2016$FL_GEBAEUDE <- j2012.2016$FL_GEBAEUDE*1
j2012.2016$FL_GEBAEUDENEBENFLAECHEN <- j2012.2016$FL_GEBAEUDENEBENFLAECHEN *0.75
j2012.2016$FL_STRASSENVERKEHRSANL <- j2012.2016$FL_STRASSENVERKEHRSANL*0.6
j2012.2016$FL_VERKEHRSRANDFLAECHEN <- j2012.2016$FL_VERKEHRSRANDFLAECHEN * 0.15
j2012.2016$FL_PARKPLAETZE <- j2012.2016$FL_PARKPLAETZE * 0.8
j2012.2016$FL_SCHIENENVERKEHRSANL <- j2012.2016$FL_SCHIENENVERKEHRSANL*0.5
j2012.2016$FL_BETRIEBSFLAECHEN <- j2012.2016$FL_BETRIEBSFLAECHEN*0.6
j2012.2016$FL_FRIEDHOEFE <- j2012.2016$FL_FRIEDHOEFE*0.35
j2012.2016$FL_FREIZEITFLAECHEN <- j2012.2016$FL_FREIZEITFLAECHEN * 0.2
j2012.2016$FL_ABBAU_HALDEN_DEPONIEN <- j2012.2016$FL_ABBAU_HALDEN_DEPONIEN *0.1



#Zusammenzählen der gewichteten versiegelten Flächen pro Katastralgemeinde und Jahr
j2012.2016$Versiegelt <- rowSums(j2012.2016[,c("FL_GEBAEUDE","FL_GEBAEUDENEBENFLAECHEN","FL_STRASSENVERKEHRSANL","FL_VERKEHRSRANDFLAECHEN","FL_PARKPLAETZE","FL_SCHIENENVERKEHRSANL","FL_BETRIEBSFLAECHEN","FL_ABBAU_HALDEN_DEPONIEN","FL_FREIZEITFLAECHEN","FL_FRIEDHOEFE")], na.rm=TRUE)

#Prozentrechnung Versiegelt/Gesamt
j2012.2016$Versiegelt_prozent <- j2012.2016$Versiegelt/j2012.2016$FL_GES_VERWALTUNGSEINHEIT

#Nettofläche



j2012.2016$FL_Netto <- with(j2012.2016, FL - FL_GLETSCHER - FL_ALPEN - FL_FLIESSENDE_GEWAESSER - FL_STEHENDE_GEWAESSER - FL_FELS_GEROELL - FL_VEGETATIONSARME_FL - FL_KRUMMHOLZFLAECHEN - FL_WAELDER)

#Prozentrechnung Versiegelt/Nettofläche
j2012.2016$Versiegelt_prozent_netto <- j2012.2016$Versiegelt/j2012.2016$Fl_Netto


## TEST

# 
# 
# write.xlsx(j2012.2016[j2012.2016$Jahr=="2016",],"./outputs/2016_ges.xlsx")



# #Gmeinde Liste 2016 rausspeichern
# gemeinden <- j2012.2016[j2012.2016$Jahr=="2016",] %>%
#   group_by(PG) %>%
#   summarize(Versiegelt=sum(Versiegelt,na.rm=TRUE),Gesamt=sum(FL_GES_VERWALTUNGSEINHEIT,na.rm=TRUE),Nettofläche=sum(Fl_Netto,na.rm=TRUE)) 
# 
# gemeinden$Prozent <- gemeinden$Versiegelt / gemeinden$Gesamt *100
# 
# gemeinden$Prozent_netto <- gemeinden$Versiegelt / gemeinden$Nettofläche *100
# 
# gemeinden <- arrange(gemeinden,desc(Prozent_netto))
# 
# write.xlsx(gemeinden, "./outputs/gemeinden.xlsx")



#################
#1995-2012
#################

dat <- readRDS("./outputs/1995-2008.rds")
dat2<- readRDS("./outputs/2009-2012.rds")

# Nur spalten die auch 1995-2008 vorhanden waren
dat2 <- dat2[,c(colnames(dat2) %in% colnames(dat))]
j1995.2012 <- rbind(dat,dat2)


#Gewichtung der Flächen lt. Email von Hrn. Banko

j1995.2012$FL_Gebäude <- j1995.2012$FL_Gebäude*1
j1995.2012$FL_befestigt <- j1995.2012$FL_befestigt *0.75
j1995.2012$"FL_BAUFLÄCHEN.n.n.u." <- j1995.2012$"FL_BAUFLÄCHEN.n.n.u." * 0.5
j1995.2012$FL_Erholungsflächen <- j1995.2012$FL_Erholungsflächen * 0.2
j1995.2012$FL_Straßenanlagen <- j1995.2012$FL_Straßenanlagen * 0.55
j1995.2012$FL_Bahnanlagen <- j1995.2012$FL_Bahnanlagen * 0.45
j1995.2012$FL_Abbauflächen <- j1995.2012$FL_Abbauflächen <- 0.1
j1995.2012$FL_SONSTIGE.n.n.u. <- j1995.2012$FL_SONSTIGE.n.n.u. * 0.6


#zusammenzählen
j1995.2012$Versiegelt <- rowSums(j1995.2012[,c("FL_Gebäude","FL_befestigt","FL_BAUFLÄCHEN.n.n.u.","FL_Erholungsflächen","FL_Straßenanlagen","FL_Bahnanlagen","FL_Abbauflächen","FL_SONSTIGE.n.n.u.")], na.rm=TRUE)

#prozent
j1995.2012$Versiegelt_prozent <- j1995.2012$Versiegelt/j1995.2012$FL_KATASTRALGEMEINDE

j1995.2012$FL_Netto <- with(j1995.2012, FL_KATASTRALGEMEINDE - FL_Ödland - FL_ALPEN - FL_fließend -	FL_stehend - FL_WALD)




################
#1979-1995
################

dat <- readRDS("./outputs/1979-1990.rds")

dat2<- readRDS("./outputs/1992-1994.rds")

# nur spalten die auch 1979-1990 vorhanden waren
dat2 <- dat2[,c(colnames(dat2) %in% colnames(dat))]
j1979.1994 <- rbind(dat,dat2)

j1979.1994$FL_Netto <- with(j1979.1994, FL_KATASTRALGEMEINDE - FL_Unproduktiv..Öde. - FL_ALPEN - FL_GEWÄSSER - FL_WALD + FL_Sümpfe)

#Gewichtung lt. Email von Hrn. Banko
j1979.1994$FL_BAUFLÄCHEN <- j1979.1994$FL_BAUFLÄCHEN*0.63
j1979.1994$FL_Bundesstraßen.A <- j1979.1994$FL_Bundesstraßen.A *0.55
j1979.1994$FL_Bundesstraßen.S.und.B <- j1979.1994$FL_Bundesstraßen.S.und.B *0.55
j1979.1994$FL_Landesstraßen <- j1979.1994$FL_Landesstraßen * 0.55
j1979.1994$FL_Bezirksstraßen <- j1979.1994$FL_Bezirksstraßen * 0.55
j1979.1994$FL_Wege <- j1979.1994$FL_Wege * 0.55
j1979.1994$FL_Straßen <- j1979.1994$FL_Straßen * 0.55
j1979.1994$FL_Gassen <- j1979.1994$FL_Gassen * 1
j1979.1994$FL_Plätze <- j1979.1994$FL_Plätze * 1
j1979.1994$FL_Ortsraum <- j1979.1994$FL_Ortsraum * 0.63
j1979.1994$FL_Bahngrund <- j1979.1994$FL_Bahngrund *0.45
j1979.1994$FL_andere.SONSTIGE <- j1979.1994$FL_andere.SONSTIGE *0.45

#zusammenzählen
j1979.1994$Versiegelt <- rowSums(j1979.1994[,c("FL_BAUFLÄCHEN","FL_Bundesstraßen.A","FL_Bundesstraßen.S.und.B","FL_Landesstraßen","FL_Bezirksstraßen","FL_Wege","FL_Straßen","FL_Gassen","FL_Plätze","FL_Ortsraum","FL_Bahngrund","FL_andere.SONSTIGE")], na.rm=TRUE)
j1979.1994$Versiegelt_prozent <- j1979.1994$Versiegelt/j1979.1994$FL_KATASTRALGEMEINDE



##############
#
# Zeitreihen für Grafiknachbau! GESAMTÖSTERREICH PER CAPITA VERSIEGELUNG
#
############

#Bevöklerung reinladen
pop <- read.xlsx("./data/statistik_austria/Bevölkerung_Österreich.xlsx")
pop$Einwohner <- as.numeric(pop$Einwohner)
pop$Jahr <- as.character(pop$Jahr)

# 2012-2016
at <- j2012.2016 %>% 
  group_by(Jahr) %>%
  summarize(Versiegelt =sum(Versiegelt,na.rm=TRUE),
            Fläche = sum(as.numeric(FL),na.rm=TRUE))

at <- left_join(at,pop)
at$versiegelt_percapita <- at$Versiegelt / at$Einwohner

#------------
# 1995-2012
at2 <- j1995.2012 %>% 
  group_by(Jahr) %>%
  summarize(Versiegelt =sum(Versiegelt,na.rm=TRUE),
            Fläche = sum(as.numeric(FL_KATASTRALGEMEINDE),na.rm=TRUE))

at2 <- left_join(at2,pop)

at2$versiegelt_percapita <- at2$Versiegelt / at2$Einwohner

at <- rbind(at,at2[at2$Jahr!="2012",])


#-----------
# 1979-1990
at3 <- j1979.1994 %>% 
  group_by(Jahr) %>%
  summarize(Versiegelt =sum(Versiegelt,na.rm=TRUE),
            Fläche = sum(as.numeric(FL_KATASTRALGEMEINDE),na.rm=TRUE))

at3 <- left_join(at3,pop)

at3$versiegelt_percapita <- at3$Versiegelt / at3$Einwohner

at <- rbind(at,at3)

at <- arrange(at,Jahr)

at$versiegelt_prozent <- at$Versiegelt/at$Fläche *100

write.xlsx2(as.data.frame(at), "./outputs/zeitreihe_at.xlsx",row.names=FALSE)


fl2<- colnames(j1995.2012)[grepl("FL",colnames(j1995.2012))]

# dat <- j1995.2012[j1995.2012$Jahr=="2012",c("BUNDESLAND",fl2)]
# 
# dat[, 2:ncol(dat)] <- sapply(dat[, 2:ncol(dat)], as.numeric)
# 
# dat <- dat %>% group_by(BUNDESLAND) %>% summarise_all(sum)
#  
# write.xlsx(dat,"./outputs/BL_test_2012_alt.xlsx")
# 
# 
# dat <- dat %>% group_by(BL) %>% summarise_all(sum)

############################
#
#
# Dataframe für Katastralgemeinden aus allen Jahren
#
#
###########################


colnames(j2012.2016)[colnames(j2012.2016) %in% colnames(j1995.2012)]

j1995.2012 <- j1995.2012[,c("Jahr","KG.NR","KATASTRALGEMEINDE","BUNDESLAND","PG.NR","POLITISCHE.GEMEINDE","Versiegelt","Versiegelt_prozent","FL_KATASTRALGEMEINDE","FL_Netto","FL_WALD")]

j1979.1994 <- j1979.1994[,c("Jahr","KG.NR","KATASTRALGEMEINDE","BUNDESLAND","PG.NR","POLITISCHE.GEMEINDE","Versiegelt","Versiegelt_prozent","FL_KATASTRALGEMEINDE","FL_Netto","FL_WALD")]

j2012.2016 <- j2012.2016[,c("Jahr","KG.NR","KG","BL","GKZ","PG","Versiegelt","Versiegelt_prozent","FL_GES_VERWALTUNGSEINHEIT","FL_Netto","FL_WAELDER")]

colnames(j2012.2016) <- c("Jahr","KG.NR","KATASTRALGEMEINDE","BUNDESLAND","PG.NR","POLITISCHE.GEMEINDE","Versiegelt","Versiegelt_prozent","FL_KATASTRALGEMEINDE","FL_Netto","FL_WALD")


j1979.2016 <- rbind(j1995.2012[j1995.2012$Jahr!="2012",],j1979.1994,j2012.2016)

saveRDS(j1979.2016,"./outputs/zeitreihe_versiegelung_gemeinden_79-16.rds")


#####################
#
# Datenframe Bundesländer
#
#####################

j1979.2016_BL <- j1979.2016[j1979.2016$Jahr>=1985,] %>%
                  group_by(Jahr,BUNDESLAND) %>%
                  summarize(Versiegelt=sum(Versiegelt,na.rm=TRUE),
                            Fläche=sum(as.numeric(FL_KATASTRALGEMEINDE),na.rm=TRUE),
                            Fläche_netto=sum(as.numeric(FL_Netto),na.rm=TRUE),
                            Wälder=sum(as.numeric(FL_WALD),na.rm=TRUE))

j1979.2016_BL$BUNDESLAND <- as.character(j1979.2016_BL$BUNDESLAND)

pop_bl <- read.xlsx("./data/statistik_austria/Bevölkerung_Bundesländer.xlsx",sheet="Tabelle1")

j1979.2016_BL <- left_join(j1979.2016_BL,pop_bl)

j1979.2016_BL$Versiegelt_percapita <- j1979.2016_BL$Versiegelt / j1979.2016_BL$Einwohner

j1979.2016_BL$Versiegelt_prozent <- j1979.2016_BL$Versiegelt / j1979.2016_BL$Fläche *100

saveRDS(j1979.2016_BL,"./outputs/zeitreihe_versiegelung_bundesländer_85-16.rds")

write.xlsx2(as.data.frame(j1979.2016_BL),"./outputs/zeitreihe_versiegelung_bundesländer_85-16.xlsx")
