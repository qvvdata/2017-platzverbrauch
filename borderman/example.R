#df <- xlsx::read.xlsx("Y:\\Austausch\\Redaktion_Austausch\\ddj\\geschichten\\2017-05-arbeitsmarkt\\01-cleaned.xlsx", sheetIndex=1)

df <- read.csv("Y:\\Austausch\\Redaktion_Austausch\\ddj\\geschichten\\2017-03-landflucht\\bevoelkerungsdaten\\bevoelkerungsstand20012014.csv",
               stringsAsFactors = FALSE)

df$gkz<-as.character(df$gkz)

df[df$bev2001=='#N/A',]$bev2001<-"0"
df[df$bev2014=='#N/A',]$bev2014<-"0"
df[df$bev2001=='-',]$bev2001<-"0"
df[df$bev2014=='-',]$bev2014<-"0"
df[is.na(df$bev2001),]$bev2001<-"0"
df[is.na(df$bev2014),]$bev2014<-"0"
df$bev2001<-as.numeric(df$bev2001)
df$bev2014<-as.numeric(df$bev2014)


df_neu<-remove_teilungen(borderman(df))

write.csv(df_neu[df_neu$bev2001>0 | df_neu$bev2014>0,],
          "Y:\\Austausch\\Redaktion_Austausch\\ddj\\geschichten\\2017-03-landflucht\\bevoelkerungsdaten\\bevoelkerungsstand20012014_bordermand.csv")