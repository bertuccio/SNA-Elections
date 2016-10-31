library(doBy)

# Load
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library("irlba")
library("plyr")
library(ggplot2) 

podemos_text <- readLines("C:/Users/pinwi/Desktop/castells_final/sent_quote_podemos.csv", encoding = "UTF-8")
ciudadanos_text <- readLines("C:/Users/pinwi/Desktop/castells_final/sent_quote_ciudadanos.csv", encoding = "UTF-8")
pp_text <- readLines("C:/Users/pinwi/Desktop/castells_final/sent_quote_pp.csv", encoding = "UTF-8")
psoe_text <- readLines("C:/Users/pinwi/Desktop/castells_final/sent_quote_psoe.csv", encoding = "UTF-8")
iu_text <- readLines("C:/Users/pinwi/Desktop/castells_final/sent_quote_iu.csv", encoding = "UTF-8")
upyd_text <- readLines("C:/Users/pinwi/Desktop/castells_final/sent_quote_upyd.csv", encoding = "UTF-8")

clean.text = function(txtclean)
{
  # remueve retweets
  txtclean = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", " ", txtclean)
  # remove @otragente
  txtclean = gsub("@\\w+", " ", txtclean)
  #remueve hashtags
  txtclean = gsub("#\\S+", " ", txtclean)
  # remueve links
  txtclean = gsub("htt\\S+", " ", txtclean)
  # remueve simbolos de puntuaciÃÂ³n
  txtclean = gsub("\\n", " ", txtclean,fixed = TRUE)
  # remueve simbolos de puntuaciÃÂ³n
  txtclean = gsub("\\r", " ", txtclean,fixed = TRUE)
  # remueve simbolos de puntuaciÃÂ³n
  txtclean = gsub("\\t", " ", txtclean,fixed = TRUE)
  txtclean = gsub("[^[:alnum:][:space:]']", " ", txtclean)
  # remove nÃÂºmerosa
  txtclean = gsub("[[:digit:]]", " ", txtclean)
  
  # remove blank spaces at the beginning
  txtclean = gsub("^ ", "", txtclean)
  # remove blank spaces at the end
  txtclean = gsub(" $", "", txtclean)

  return(txtclean)
}


podemos_clean = clean.text(podemos_text)
ciudadanos_clean = clean.text(ciudadanos_text)
pp_clean = clean.text(pp_text)
psoe_clean = clean.text(psoe_text)
iu_clean = clean.text(iu_text)
upyd_clean = clean.text(upyd_text)



write.csv(podemos_clean,"gen_quot_podemos_clean.csv")
write.csv(ciudadanos_clean,"gen_quot_ciudadanos_clean.csv")
write.csv(pp_clean,"gen_quot_pp_clean.csv")
write.csv(psoe_clean,"gen_quot_psoe_clean.csv")
write.csv(iu_clean,"gen_quot_iu_clean.csv")
write.csv(upyd_clean,"gen_quot_upyd_clean.csv")
# podemos = paste(podemos_clean, collapse=" ")
# ciudadanos = paste(ciudadanos_clean, collapse=" ")
# 
# all = c(podemos, ciudadanos)


podemos = paste(podemos_clean, collapse=" ")
ciudadanos = paste(ciudadanos_clean, collapse=" ")
pp = paste(pp_clean, collapse=" ")
psoe = paste(psoe_clean, collapse=" ")
iu = paste(iu_clean, collapse=" ")
upyd = paste(upyd_clean, collapse=" ")
sw <- readLines("stopwords.cat.txt",encoding = "UTF-8")
all = c(podemos, ciudadanos,pp,psoe,iu,upyd)
# create corpus
corpus = Corpus(VectorSource(all))
# carga archivo de palabras vacÃï¿½as personalizada y lo convierte a ASCII
sw2 <- readLines("tabu.txt",encoding = "UTF-8")
sw2 = iconv(sw, to="ASCII//TRANSLIT")
# # remueve palabras vacÃï¿½as personalizada
corpus <- tm_map(corpus, removeWords, sw2)
corpus <- tm_map(corpus, removeWords, sw)


# Convert the text to lower case
corpus <- tm_map(corpus, content_transformer(tolower))

# Remove numbers
corpus <- tm_map(corpus, removeNumbers)

# # Remove spanish common stopwords
corpus <- tm_map(corpus, removeWords, stopwords("spanish"))



corpus <- tm_map(corpus, removeWords, c("vota","candidato","campa�a","hoy","elecciones"))

corpus <- tm_map(corpus, removeWords, stopwords("english"))

corpus <- tm_map(corpus, removeWords, c("d�a","ahora","partidos","vot","aquest","meu","vots","votat","per","jornada","reflexió"))


corpus <- tm_map(corpus, removeWords, c("vot","aquest","meu"))
corpus <- tm_map(corpus, removeWords, c("vota","candidato","campa�a","hoy","elecciones"))
corpus <- tm_map(corpus, removeWords, c("dia","d�a","ahora","partidos"))
corpus <- tm_map(corpus, removeWords, c("vot","aquest","catalu�a"))
corpus <- tm_map(corpus, removeWords, c("jornada","reflexi�","eis","vots","ens","auvi"))
corpus <- tm_map(corpus, removeWords, c("per","diumenge","dem�","tothom","amb","avui"))
corpus <- tm_map(corpus, removeWords, c("votar","catalunya","catalonia","participaci�","votado","participaci�n"))
corpus <- tm_map(corpus, removeWords, c("momento","catalans","pels","pot","voto","votat","vote","gr�cies"))

# 
# # Remove english common stopwords
# corpus <- tm_map(corpus, removeWords, stopwords("english"))


# Remove punctuations
corpus <- tm_map(corpus, removePunctuation)

# Eliminate extra white spaces
corpus <- tm_map(corpus, stripWhitespace)


# create term-document matrix
dtm = TermDocumentMatrix(corpus)


m <- sparseMatrix(
  i = dtm$i, j = dtm$j, x = dtm$v,
  dims = c(dtm$nrow, dtm$ncol), dimnames = dtm$dimnames
)



m2 <-as.matrix(m)

# add column names
colnames(m2) = c("Catsiq", "C's","PP","PSC","CUP","JxSi")

commonality.cloud(m2, random.order=FALSE, 
                  colors = brewer.pal(8, "Dark2"),
                  title.size=1.5,max.words=5000)

comparison.cloud(m2, random.order=FALSE, 
                 colors = c("#c4375b","#ec762d","#1ba5e2","#df1223","#e6da00","#38b7a4"),
                 title.size=1.5, max.words=2000)
