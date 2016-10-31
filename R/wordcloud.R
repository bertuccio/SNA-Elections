


# install.packages("doBy")
# install.packages("tm")
# install.packages("SnowballC")
# install.packages("RColorBrewer")
# install.packages("plyr")
# install.packages("ggplot2")
# install.packages("wordcloud")

# Load
library(tm)
library(SnowballC)
library(wordcloud2)
library(RColorBrewer)
# library(irlba)
library(plyr)
library(ggplot2) 
# library(doBy)
setwd("/home/pinwi/workspace/SNAElections/R/")
tweets_text <- read.csv("../resources/tweets_out.csv",sep = ",")

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
  # remueve simbolos de puntuacion
  txtclean = gsub("\\n", " ", txtclean,fixed = TRUE)
  # remueve simbolos de puntuacion
  txtclean = gsub("\\r", " ", txtclean,fixed = TRUE)
  # remueve simbolos de puntuacion
  txtclean = gsub("\\t", " ", txtclean,fixed = TRUE)
  txtclean = gsub("[^[:alnum:][:space:]']", " ", txtclean)
  # remove numeros
  txtclean = gsub("[[:digit:]]", " ", txtclean)
  
  # remove blank spaces at the beginning
  txtclean = gsub("^ ", "", txtclean)
  # remove blank spaces at the end
  txtclean = gsub(" $", "", txtclean)

  return(txtclean)
}


tweets_text = clean.text(tweets_text$text)


# create corpus
corpus = Corpus(VectorSource(tweets_text))
# carga archivo de palabras vacÃï¿½as personalizada y lo convierte a ASCII


# Convert the text to lower case
corpus <- tm_map(corpus, content_transformer(tolower))

# Remove numbers
corpus <- tm_map(corpus, removeNumbers)

corpus <- tm_map(corpus, removeWords, stopwords("english"))

corpus <- tm_map(corpus, removeWords, c("elections","election"))


# Remove punctuations
corpus <- tm_map(corpus, removePunctuation)

# Eliminate extra white spaces
corpus <- tm_map(corpus, stripWhitespace)

# tdm = TermDocumentMatrix(corpus, control = list(removePunctuation = TRUE,stopwords = c("machine", "learning", stopwords("english")), removeNumbers = TRUE, tolower = TRUE))
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
