
# install.packages("doBy")
# install.packages("tm")
# install.packages("SnowballC")
# install.packages("RColorBrewer")
# install.packages("plyr")
# install.packages("ggplot2")
# install.packages("wordcloud")
# install.packages("Matrix")

# Load
library(tm)
library(SnowballC)
library(RColorBrewer)
library(wordcloud)
# library(irlba)
library(plyr)
library(ggplot2) 
library(doBy)
library(Matrix)

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


# Get the files names

path_files <- "resources/csv/hashtags/"
hashtag_lists_path = list.files(path=path_files, pattern="*.csv", full.names = TRUE)
hashtag_lists_names = list.files(path=path_files, pattern="*.csv")

# ptm <- proc.time()
df_list <- llply(hashtag_lists_path, read.csv, header=T, fileEncoding="UTF-8")
names(df_list) <- hashtag_lists_names
# proc.time() - ptm


# lapply(df_list, function(x)  clean.text(x$text)) 

for(name in names(df_list)) {
  text = clean.text(df_list[[name]]$text)
  
  corpus = Corpus(VectorSource(text))
  
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, removeWords, c("elections","election"))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  
  dtm = TermDocumentMatrix(corpus)
  m <- sparseMatrix(
    i = dtm$i, j = dtm$j, x = dtm$v,
    dims = c(dtm$nrow, dtm$ncol), dimnames = dtm$dimnames
  )
  
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  image_name <- strsplit(name,"\\.")[[1]][1]
  png(filename = paste0("outputs/images/",image_name,".png"), width=12, height=8, units="in", res=300)
  
  wordcloud(words = d$word, freq = d$freq, min.freq = 1,
            max.words=400, random.order=FALSE, rot.per=0.35, 
            colors=brewer.pal(8, "Dark2"))
  
  # save the image in png format
  # wordcloud(dm$word, dm$freq, random.order=FALSE, colors=brewer.pal(8, "Dark2"))
  dev.off()
}

# commonality.cloud(m2, random.order=FALSE, 
#                   colors = brewer.pal(8, "Dark2"),
#                   title.size=1.5,max.words=5000)
# 
# comparison.cloud(m2, random.order=FALSE, 
#                  colors = c("#c4375b","#ec762d","#1ba5e2","#df1223","#e6da00","#38b7a4"),
#                  title.size=1.5, max.words=2000)
