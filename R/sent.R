# Install
#install.packages("tm")  # for text mining
#install.package("SnowballC") # for text stemming
#install.packages("wordcloud") # word-cloud generator
#install.packages("RColorBrewer") # color palettes
#install.packages("irlba") # for sparseMatrix
# install.packages("RSQLite")
# install.packages("plyr")
# install.packages("stringr")
# install.packages("ggplot2")
library(doBy)

start.time.total <- Sys.time()
# Load
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library("irlba")
library("plyr")
library(ggplot2) 

score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)
  
  scores = laply(sentences, function(sentence, pos.words, neg.words){
    
    sentence = tolower(sentence)
    word.list = str_split(sentence, '\\s+')
    words = unlist(word.list)
    
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    
    
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    
    score = sum(pos.matches) - sum(neg.matches)
    
    return(score)
  }, pos.words, neg.words, .progress=.progress)
  
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}

# # Assign the sqlite datbase and full path to a variable
# dbfile = "C:/Users/pinwi/Documents/twitterdbf.db";
# 
# # Instantiate the dbDriver to a convenient object
# sqlite = dbDriver("SQLite");
# 
# # connect to the sqlite file
# con = dbConnect(sqlite,dbfile)

# Read the text file


# fileQuotedUsers.pp <- "C:/Users/pinwi/Documents/PROYECTO/quoted_official_users_pp.csv"
# fileQuotedUsers.cs <- "C:/Users/pinwi/Documents/PROYECTO/quoted_official_users_ciudadanos.csv"
# fileQuotedUsers.jxsi <- "C:/Users/pinwi/Documents/PROYECTO/quoted_official_users_jxsi.csv"

fileQuotedUsers.pp <- "C:/Users/pinwi/Desktop/h_pp.csv"
fileQuotedUsers.cs <- "C:/Users/pinwi/Desktop/h_cs.csv"
fileQuotedUsers.jxsi <- "C:/Users/pinwi/Desktop/h_jxsi.csv"
fileQuotedUsers.psc <- "C:/Users/pinwi/Desktop/h_psc.csv"
fileQuotedUsers.cup <- "C:/Users/pinwi/Desktop/h_cup.csv"
fileQuotedUsers.catsiqueespot <- "C:/Users/pinwi/Desktop/h_catsqp.csv"
fileQuotedUsers.unio <- "C:/Users/pinwi/Desktop/h_unio.csv"

sw <- readLines("stopwords.cat.txt",encoding = "UTF-8")

positive <- c(scan("senticon.es.pos.txt", what='character',comment.char=';'),
              scan("senticon.cat.pos.txt", what='character',comment.char=';'))
negative <- c(scan("senticon.es.neg.txt", what='character',comment.char=';'),
              scan("senticon.cat.neg.txt", what='character',comment.char=';'))

# results = dbSendQuery(
#   con, "select distinct(text) from tweets join hashtags on tweets.id=hashtags.tweet_id where quoted_status_id=-1 and quoted_user_id=-1 and retweet_id=-1 and in_reply_to_status_id=-1 and in_reply_to_user_id=-1 and (upper(hashtag)='27S' or  upper(hashtag)='ELECCIONESCATALANAS')"
# );


# Return results from a custom object to a data.frame

# data = fetch(results, n=-1);
# dbClearResult(results)
# dbDisconnect(con)

fileList <- c(fileQuotedUsers.pp, fileQuotedUsers.cs,fileQuotedUsers.jxsi,
              fileQuotedUsers.psc,fileQuotedUsers.cup,fileQuotedUsers.catsiqueespot,
              fileQuotedUsers.unio)
partyList <- c("PP","C's", "JxSi","PSC","CUP","CatsiQueesPot","Unió")
listaResultados <- NULL

for (index in 1:length(fileList)) {
  
  
  start.time.lectura <- Sys.time()
  ##### inicio limpieza de datos #####
  # text <- enc2utf8(data$text)
  
  path <- fileList[index]
  
  text <- readLines(path, encoding = "UTF-8")
  # remueve retweets
  txtclean = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", " ", text)
  # remove @otragente
  txtclean = gsub("@\\w+", " ", txtclean)
  #remueve hashtags
  txtclean = gsub("#\\S+", " ", txtclean)
  # remueve links
  txtclean = gsub("htt\\S+", " ", txtclean)
  # remueve simbolos de puntuaciÃ³n
  txtclean = gsub("\\n", " ", txtclean,fixed = TRUE)
  # remueve simbolos de puntuaciÃ³n
  txtclean = gsub("\\r", " ", txtclean,fixed = TRUE)
  # remueve simbolos de puntuaciÃ³n
  txtclean = gsub("\\t", " ", txtclean,fixed = TRUE)
  txtclean = gsub("[^[:alnum:][:space:]']", " ", txtclean)
  # remove nÃºmerosa
  txtclean = gsub("[[:digit:]]", " ", txtclean)
  ##### fin limpieza de datos #####
  end.time.lectura <- Sys.time()
  
  time.taken.lectura <- end.time.lectura - start.time.lectura
  
  
  # Load the data as a corpus
  docs <- Corpus(VectorSource(txtclean))
  
  # toSpace <-
  #   content_transformer(function (x , pattern)
  #     gsub(pattern, " ", x))
  #docs <- tm_map(docs, toSpace, "/")
  #docs <- tm_map(docs, toSpace, "@")
  #docs <- tm_map(docs, toSpace, "\\|")
  
  start.time.stopwords <- Sys.time()
  # carga archivo de palabras vacÃ�as personalizada y lo convierte a ASCII
  #   sw <- readLines("stopwords.cat.txt",encoding = "UTF-8")
  # remueve palabras vacÃ�as personalizada
  docs = tm_map(docs, removeWords, sw)
  
  # Convert the text to lower case
  docs <- tm_map(docs, content_transformer(tolower))
  
  # Remove numbers
  docs <- tm_map(docs, removeNumbers)
  
  # Remove spanish common stopwords
  docs <- tm_map(docs, removeWords, stopwords("spanish"))
  
  # Remove english common stopwords
  # docs <- tm_map(docs, removeWords, stopwords("english"))
  
  
  # Remove punctuations
  docs <- tm_map(docs, removePunctuation)
  
  # Eliminate extra white spaces
  docs <- tm_map(docs, stripWhitespace)
  
  
  # Text stemming
  # docs <- tm_map(docs, stemDocument, language = "spanish")
  
  end.time.stopwords <- Sys.time()
  
  time.taken.stopwords <- end.time.stopwords - start.time.stopwords
  
  start.time.matrix <- Sys.time()
  
  dtm <- TermDocumentMatrix(docs)
  
  # dtm.common = removeSparseTerms(dtm, 0.1)
  
  m <- sparseMatrix(
    i = dtm$i, j = dtm$j, x = dtm$v,
    dims = c(dtm$nrow, dtm$ncol), dimnames = dtm$dimnames
  )
  
  # m <- as.matrix(dtm)
  
  v <- sort(rowSums(m),decreasing = TRUE)
  d <- data.frame(word = names(v),freq = v)
  
  end.time.matrix <- Sys.time()
  
  time.taken.matrix <- end.time.matrix - start.time.matrix
  
  head(d,10)
  set.seed(1234)
  
  pdf(paste("sentiment",as.character(partyList[index]),"pdf", sep = "."))
  
    wordcloud(
      words = d$word, freq = d$freq, min.freq = 1,
      max.words = 200, random.order = FALSE, rot.per = 0.35,
      colors = brewer.pal(8, "Dark2")
    )
  
    findFreqTerms(dtm, lowfreq = 2000)
    findAssocs(dtm, terms = "catalunya", corlimit = 0.1)
  
  #write(t(d), file = "data");
  
    barplot(
      d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
      col = "lightblue", main = "Most frequent words",
      ylab = "Word frequencies"
    )
  
  end.time.total <- Sys.time()
  
  time.taken.total <- end.time.total - start.time.total
  
  #   positive <- c(scan("senticon.es.pos.txt", what='character',comment.char=';'),
  #                 scan("senticon.cat.pos.txt", what='character',comment.char=';'))
  #   negative <- c(scan("senticon.es.neg.txt", what='character',comment.char=';'),
  #                 scan("senticon.cat.neg.txt", what='character',comment.char=';'))
  
  dataframe<-data.frame(text=unlist(sapply(docs, '[', "content")), 
                        stringsAsFactors=F)
  
  resultado <- score.sentiment(dataframe$text, positive, negative)
  resultado$score
  resultado$partido = partyList[index]
  listaResultados <- c(listaResultados,list(resultado))
  
  
  resultado <- score.sentiment(txtclean, positive, negative)
  
    qplot(x=resultado$score,geom="histogram") 
    
    slices <- c(sum(resultado$score < 0),sum(resultado$score == 0),sum(resultado$score > 0))
    
    labels <- c("Negative", "Neutral", "Positive")
    percents  <- round(slices/sum(slices)*100)
    labels <- paste(labels, percents) # add percents to labels
    labels <- paste(labels,"%",sep="") # ad % to labels
    
    cols <- colorRampPalette(brewer.pal(3,"Set1"))(length(labels));
    
    pie(slices,labels, col=cols,
        main="Sentiment of #27S") 
    
    "Lectura Fichero"; time.taken.lectura
    "Stopwords"; time.taken.stopwords
    "Matrix"; time.taken.matrix
    "Total"; time.taken.total
  
    dev.off()
  
  all.scores <- rbind.fill(listaResultados)
  
  
}
# 
# pdf("sentiment&votes.pdf")
# 
# 
# g = ggplot(data=all.scores, mapping=aes(x=score, fill=partido) )
# g = g + geom_bar(binwidth=1)
# g = g + facet_grid(partido~.) +  theme_bw() 
# g
# 
# 
# all.scores$very.pos.bool = all.scores$score >= 2
# all.scores$very.neg.bool = all.scores$score <= -2
# all.scores$very.pos = as.numeric( all.scores$very.pos.bool )
# all.scores$very.neg = as.numeric( all.scores$very.neg.bool )
# 
# twitter.df = ddply(all.scores, 'partido', summarise,
#                    very.pos.count=sum( very.pos ),
#                    very.neg.count=sum( very.neg ) )
# 
# twitter.df$very.tot = twitter.df$very.pos.count +
#   twitter.df$very.neg.count
# 
# twitter.df$score = round( 100 * twitter.df$very.pos.count /
#                             twitter.df$very.tot )
# orderBy(~-score, twitter.df)
# 
# #cis.score <- c(9.4,14.8,38.1,12.2,5.9,13.9,1.5)
# votes.score <- c(8.2,17.93,39.54,12.74,8.2,8.94,2.51)
# #partyList <- c("PP","C's", "JxSi","PSC","CUP","CatsiQueesPot","Unió")
# #cis.score <- c(348444,734910,1620973,522209,336375,366494,102870)
# #cis.score <- c(11,25,62,16,10,11,0)
# votes.df <- data.frame(partyList,votes.score)
# colnames(votes.df) = c('partido', 'score')
# votes.df$score = as.numeric(votes.df$score)
# 
# compare.df = merge(twitter.df, votes.df, by='partido',
#                    suffixes=c('.twitter', '.votes'))
# 
# 
# 
# g = ggplot( compare.df, aes(x=score.twitter, y=score.votes) ) +
#   geom_point( aes(color=partido), size=5 ) +
#   theme_bw() + theme( legend.position=c(0.2, 0.85) )
# 
# g = g + geom_smooth(aes(group=1), se=F, method="lm")
# g
# 
# dev.off()