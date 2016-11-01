# Install
#install.packages("tm")  # for text mining
#install.package("SnowballC") # for text stemming
#install.packages("wordcloud") # word-cloud generator
#install.packages("RColorBrewer") # color palettes
# install.packages("irlba") # for sparseMatrix
# install.packages("RSQLite")
# install.packages("plyr")
# install.packages("stringr")
# install.packages("ggplot2")
# install.packages("lubridate")
# install.packages("dplyr")
# install.packages("rJava")
# install.packages("syuzhet")




# Load
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library("irlba")
library("plyr")
library(ggplot2) 
library(RSQLite)
library(lubridate)
library(scales)
library(doBy)

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

setwd("/home/pinwi/workspace/SNAElections")
# connect to the sqlite file
con = dbConnect(drv=RSQLite::SQLite(), dbname="twitterdb.db")

# get a list of all tables
# alltables = dbListTables(con)
# dbListFields(con, "Tweets")

# print(alltables)


ptm <- proc.time()
tweets = dbGetQuery( con,'select CAST(id as TEXT) as id, replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( lower(text), \'á\',\'a\'), \'Á\',\'a\'), \'à\',\'a\'), \'À\',\'a\'), \'è\',\'e\'), \'é\',\'e\'), \'È\',\'e\'),\'É\',\'e\'),\'Ì\',\'i\'),\'í\',\'i\'),\'Í\',\'i\'),\'ì\',\'i\'),\'ó\',\'o\') ,\'ò\',\'o\'),\'Ó\',\'o\') ,\'Ò\',\'o\') ,\'ú\',\'u\'), \'ù\',\'u\') ,\'Ú\',\'u\'), \'Ù\',\'u\') as text, 	strftime(\'%Y-%m-%d %H:%M:%S\',created_at/1000,\'unixepoch\') as created, CAST(retweet_id as TEXT) as retweet_id, CAST(quoted_user_id as TEXT) as quoted_user_id from tweets' )
tweets$id = as.numeric(tweets$id)
tweets$retweet_id = as.numeric(tweets$retweet_id)
tweets$quoted_user_id = as.numeric(tweets$quoted_user_id)
proc.time() - ptm

# Encoding(tweets$text) <- "UTF-8"
tweets$text <- iconv(tweets$text, 'UTF-8', 'ASCII')
tweets$text = clean.text(tweets$text)
tweets$created <- ymd_hms(tweets$created)
tweets$created <- with_tz(tweets$created, "America/Chicago")

tweets$type <- "tweet"
tweets[tweets$retweet_id != -1,"type"] <- "RT"
tweets[(tweets$quoted_user_id != -1),"type"] <- "quoted"
tweets$type <- as.factor(tweets$type)
tweets$type = factor(tweets$type,levels(tweets$type)[c(3,1,2)])


# ggplot(data = tweets, aes(x = created, fill = type)) +
#   geom_histogram() +
#   xlab("Time") + ylab("Number of tweets") +
#   scale_x_datetime(breaks = date_breaks("3 hours"), 
#                    labels = date_format("%H")) +
#   scale_fill_manual(values = c("midnightblue", "deepskyblue4", "aquamarine3"))

# png(filename = paste0("outputs/images/proportion.png"), width=12, height=8, units="in", res=300)
# 
# 
# # ggplot(data = tweets, aes(x = created, fill = type)) +
#   geom_bar(position = "fill") +
#   xlab("Time") + ylab("Proportion of tweets") +
#   scale_fill_manual(values = c("midnightblue", "deepskyblue4", "aquamarine3"))
# dev.off()


library(reshape2)
library(dplyr)
library(syuzhet)

mySentiment <- get_nrc_sentiment(tweets$text)
tweets <- cbind(tweets, mySentiment)

sentimentTotals <- data.frame(colSums(tweets[,c(7:16)]))
names(sentimentTotals) <- "count"
sentimentTotals <- cbind("sentiment" = rownames(sentimentTotals), sentimentTotals)
rownames(sentimentTotals) <- NULL

png(filename = paste0("outputs/images/sentiment.png"), width=12, height=8, units="in", res=300)
ggplot(data = sentimentTotals, aes(x = sentiment, y = count)) +
  geom_bar(aes(fill = sentiment), stat = "identity") +
  theme(legend.position = "none") +
  xlab("Sentiment") + ylab("Total Count") + ggtitle("Total Sentiment Score for All Tweets")

dev.off() 


corpus = Corpus(VectorSource(tweets$text))

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
png(filename = paste0("outputs/images/wordcloud_total.png"), width=12, height=8, units="in", res=300)

wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=400, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))
dev.off()

# library(reshape2)
# library(dplyr )
# 
# tweets$weekday <- wday(tweets$created, label = TRUE)
# weeklysentiment <- tweets %>% group_by(weekday) %>% 
#   summarise(anger = mean(anger), 
#             anticipation = mean(anticipation), 
#             disgust = mean(disgust), 
#             fear = mean(fear), 
#             joy = mean(joy), 
#             sadness = mean(sadness), 
#             surprise = mean(surprise), 
#             trust = mean(trust)) %>% melt
# names(weeklysentiment) <- c("weekday", "sentiment", "meanvalue")
# 
# ggplot(data = weeklysentiment, aes(x = weekday, y = meanvalue, group = sentiment)) +
#   geom_line(size = 2.5, alpha = 0.7, aes(color = sentiment)) +
#   geom_point(size = 0.5) +
#   ylim(0, 0.6) +
#   theme(legend.title=element_blank(), axis.title.x = element_blank()) +
#   ylab("Average sentiment score") + 
#   ggtitle("Sentiment During the Week")
# tweets[(minute(tweets$created) == 0 & second(tweets$created) == 0),"timeonly"] <- NA
# mean(is.na(tweets$timeonly))
# class(tweets$timeonly) <- "POSIXct"
# 
# ggplot(data = tweets, aes(x = created, fill = type)) +
#   geom_histogram() +
#   theme(legend.position = "none") +
#   xlab("Time") + ylab("Number of tweets") + 
#   scale_x_datetime(breaks = date_breaks("2 days"), 
#                    labels = date_format("%d")) +
#   scale_fill_gradient(low = "midnightblue", high = "aquamarine4")
# 
# 
# print(tweets[[1]])
# corpus = Corpus(VectorSource(text))
# 
# corpus <- tm_map(corpus, content_transformer(tolower))
# corpus <- tm_map(corpus, removeNumbers)
# corpus <- tm_map(corpus, removeWords, stopwords("english"))
# corpus <- tm_map(corpus, removeWords, c("elections","election"))
# corpus <- tm_map(corpus, removePunctuation)
# corpus <- tm_map(corpus, stripWhitespace)
# # count the areas in the SQLite table
# p2 = dbGetQuery( con,'select count(*) from areastable' )
# # find entries of the DB from the last week
# p3 = dbGetQuery(con, "SELECT population WHERE DATE(timeStamp) < DATE('now', 'weekday 0', '-7 days')")
# #Clear the results of the last query
# dbClearResult(p3)
# #Select population with managerial type of job
# p4 = dbGetQuery(con, "select * from populationtable where jobdescription like '%manager%'")
# 



