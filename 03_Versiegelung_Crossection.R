
tablecruncher <- function(data,Jahr,aggregator,flaeche){
  
  #NA auf 0 setzten
  data[is.na(data)] <- 0
  
  #Berechnung der verwendeten Variablen
  data$Besiedelbar <- with(data,FL - FL_GLETSCHER - FL_ALPEN - FL_FLIESSENDE_GEWAESSER - FL_STEHENDE_GEWAESSER - FL_FELS_GEROELL - FL_VEGETATIONSARME_FL - FL_KRUMMHOLZFLAECHEN - FL_WAELDER -FL_GEWAESSERRANDFLAECHEN)
  
  data$Baufläche  <- with(data, FL_GEBAEUDE + FL_GEBAEUDENEBENFLAECHEN + FL_BETRIEBSFLAECHEN + FL_FRIEDHOEFE + FL_GAERTEN)
  data$Landwirtschaftlich <- with(data, FL_DAUERKULTUR_ERWERB + FL_AECKER_WIESEN_WEIDEN + FL_WEINGAERTEN + FL_VERBUSCHTE_FLAECHEN)
  data$Verkehrsfläche <- with(data, FL_STRASSENVERKEHRSANL + FL_VERKEHRSRANDFLAECHEN + FL_PARKPLAETZE + FL_SCHIENENVERKEHRSANL)
  data$Dauersiedelungsraum  <- with(data, Baufläche + Landwirtschaftlich + Verkehrsfläche + FL_FREIZEITFLAECHEN + FL_ABBAU_HALDEN_DEPONIEN)
  
  #getting all colnames starting with "FL_"
  fl<- colnames(data)[grepl("FL_",colnames(data))]
  
  fl2<- colnames(data)[grepl("FL",colnames(data))]
  
  # #getting all colnames containing "BL" and FL
  # dat <- data[data$Jahr=="2012",c("BL",fl2)]
  # #setting to numeric
  # dat[, 2:ncol(dat)] <- sapply(dat[, 2:ncol(dat)], as.numeric)
  # #aggregating for further analysis
  # dat <- dat %>% group_by(BL) %>% summarise_all(sum)
  # write.xlsx(dat,"./outputs/2016_cross_BL_test_2012_2.xlsx")
  
  #Aggregierung des Datenframes anahand der variable "aggregator"
  #Wenn bspw. Bundesländer gefragt sind sollte aggregator auf "BL" gesetzt werden
  
  bl <- data[data$Jahr==Jahr,] %>%
    group_by(get(aggregator)) %>%
    summarize(Fläche = sum(as.numeric(FL)),
              
              Besiedelbar = sum(Besiedelbar),
              
              Dauersiedelungsraum = sum(Dauersiedelungsraum),
              
              Baufläche=sum(Baufläche),
              
              Versiegelte_Baufläche = sum(FL_GEBAEUDE) +
                sum(FL_GEBAEUDENEBENFLAECHEN)*0.75+
                sum(FL_BETRIEBSFLAECHEN)*0.6+
                sum(FL_FRIEDHOEFE)*0.35,
              
              Verkehrsfläche=sum(Verkehrsfläche),
              
              Versiegelte_Verkehrsfläche = (sum(FL_STRASSENVERKEHRSANL)*0.6 +
                                              sum(FL_VERKEHRSRANDFLAECHEN)*0.15+
                                              sum(FL_PARKPLAETZE)*0.8+
                                              sum(FL_SCHIENENVERKEHRSANL)*0.5),
              
              Freizeitfläche=sum(FL_FREIZEITFLAECHEN),
              
              Abbaufläche=sum(FL_ABBAU_HALDEN_DEPONIEN),
              
              Betriebsflächen=sum(FL_BETRIEBSFLAECHEN),
              
              Friedhöfe=sum(FL_FRIEDHOEFE),
              
              Wald=sum(FL_WAELDER))
  
  if (flaeche=="km2") {bl[2:ncol(bl)] <- bl[2:ncol(bl)]/10^6}
  
  if (flaeche=="ha") {bl[2:ncol(bl)] <- bl[2:ncol(bl)]/10^4}
  
  
  bl <- bl %>% mutate(Anteil_DSR_Fläche = Dauersiedelungsraum/Fläche*100,
                      Anteil_DSR_Besiedelbar = Dauersiedelungsraum/Besiedelbar*100,
                      Bau_und_Verkehrsfläche = Baufläche+Verkehrsfläche,
                      Versiegelte_Bau_und_Verkehrsfläche = Versiegelte_Verkehrsfläche + Versiegelte_Baufläche,
                      Versiegelungsgrad_Baufläche=Versiegelte_Baufläche/Baufläche*100,
                      Flächeninanspruchnahme = Baufläche + Verkehrsfläche + Freizeitfläche + Abbaufläche,
                      Anteil_Inanspruchnahme_Siedlungsraum = Flächeninanspruchnahme/Dauersiedelungsraum*100,
                      Versiegelte_Fläche_gesamt = Versiegelte_Bau_und_Verkehrsfläche + Abbaufläche*0.1 + Freizeitfläche*0.2,
                      Gesamtversiegelungsgrad= (Versiegelte_Bau_und_Verkehrsfläche + Abbaufläche*0.1 + Freizeitfläche*0.2)/Flächeninanspruchnahme*100)
  
  
  bl <-bl[,c(
    "get(aggregator)",
    "Fläche",
    "Besiedelbar",
    "Dauersiedelungsraum",
    "Anteil_DSR_Fläche",
    "Anteil_DSR_Besiedelbar",
    "Baufläche",
    "Versiegelte_Baufläche",
    "Verkehrsfläche",
    "Versiegelte_Verkehrsfläche",
    "Bau_und_Verkehrsfläche",
    "Versiegelte_Bau_und_Verkehrsfläche",
    "Versiegelungsgrad_Baufläche",
    "Freizeitfläche",
    "Abbaufläche",
    "Betriebsflächen",
    "Friedhöfe",
    "Flächeninanspruchnahme",
    "Anteil_Inanspruchnahme_Siedlungsraum",
    "Versiegelte_Fläche_gesamt",
    "Gesamtversiegelungsgrad",
    "Wald")]
  
  bl[2:ncol(bl)] <- round(bl[2:ncol(bl)],digits=2)
  
  colnames(bl)[1] <- aggregator
  
  #bl <- arrange(bl,desc(Gesamtversiegelungsgrad))
  return (bl)
}