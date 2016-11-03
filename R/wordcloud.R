
# install.packages("doBy")
# install.packages("tm")
# install.packages("SnowballC")
# install.packages("RColorBrewer")
# install.packages("plyr")
# install.packages("ggplot2")
# install.packages("wordcloud")
# install.packages("irlba")

# Load
library(tm) #text minning
library(SnowballC) #stowords
library(RColorBrewer)
library(wordcloud)
library(irlba) #for Matrix
library(plyr) #for llply
library(ggplot2) 
library(doBy)

# Sentiment

library(reshape2)
library(dplyr)
library(syuzhet)

setwd("/home/pinwi/workspace/SNAElections")

source("R/clean.text.R")

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
  sw <- readLines("resources/stopwords",encoding="UTF-8")
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, removeWords, sw)
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
  image_name <- gsub("^.*_","#", image_name)
  
  png(filename = paste0("outputs/images/",image_name,".png"), width=12, height=8, units="in", res=300)
  layout(matrix(c(1, 2), nrow=2), heights=c(1, 10))
  par(mar=rep(0, 4))
  plot.new()
  text(x=0.5, y=0.5, paste0("Wordcloud for ",image_name),cex=1.5)
  wordcloud(words = d$word, freq = d$freq, min.freq = 1,
            max.words=400, random.order=FALSE, rot.per=0.35,
            colors=brewer.pal(8, "Dark2"), main="Title")

  dev.off()
  
  
  png(filename = paste0("outputs/images/freqwords_",image_name,".png"), width=12, height=8, units="in", res=300)
  # findFreqTerms(dtm, lowfreq = 4)
  barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
          col ="lightblue", main =paste0("Most frequent words for ",image_name),
          ylab = "Word frequencies")
  dev.off()
  
  mySentiment <- get_nrc_sentiment(text)
  sentimentTotals <- data.frame(colSums(mySentiment))
  names(sentimentTotals) <- "count"
  sentimentTotals <- cbind("sentiment" = rownames(sentimentTotals), sentimentTotals)
  rownames(sentimentTotals) <- NULL

  png(filename = paste0("outputs/images/sentiment_",image_name,".png"), width=12, height=8, units="in", res=300)
  p = ggplot(data = sentimentTotals, aes(x = sentiment, y = count)) +
    geom_bar(aes(fill = sentiment), stat = "identity") +
    theme(legend.position = "none") +
    xlab("Sentiment") + ylab("Total Count") + ggtitle(paste0("Sentiment Score for ",image_name))
  print(p)
  dev.off()
  
  
  
  
  # save the image in png format
  # wordcloud(dm$word, dm$freq, random.order=FALSE, colors=brewer.pal(8, "Dark2"))
  
}

# 

# commonality.cloud(m2, random.order=FALSE, 
#                   colors = brewer.pal(8, "Dark2"),
#                   title.size=1.5,max.words=5000)
# 
# comparison.cloud(m2, random.order=FALSE, 
#                  colors = c("#c4375b","#ec762d","#1ba5e2","#df1223","#e6da00","#38b7a4"),
#                  title.size=1.5, max.words=2000)
