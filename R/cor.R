
# install.packages("Metrics")
# install.packages("gridExtra")
library(Metrics)
library(ggplot2)
library(gridExtra)
library(scales)
get.prob = function(elements, total, .progress='none')
{
  require(plyr)
  
  probs = laply(elements, function(element){
    
    return (element/sum(total))
    
  }, .progress=.progress)
  return (probs)
}


comunidades = read.csv(sep = "\t",
 "C:/Users/pinwi/Desktop/castells_final/cataluña/procesado/procesado_gephi/archivos_gephi/comunidad_quote2.csv",
 encoding = "UTF-8")


# resultados.votaciones = read.csv("C:/Users/pinwi/Documents/cat_porcentaje_votos.csv", encoding = "UTF-8")
resultados.votaciones = read.csv("C:/Users/pinwi/Documents/porcentaje_votos.csv", encoding = "UTF-8")

# comunidades = read.csv(sep = "\t",
#  "data/gephi_output/filtered_parties/retweet_communities_nodes.csv",
#  encoding = "UTF-8")


# retweets = read.csv(sep = "\t",
#                      "C:/Users/pinwi/Documents/partidos_hashtags.csv",
#                      encoding = "UTF-8")

# retweets = read.csv(
#                      "C:/Users/pinwi/Documents/quoted_partidos.csv",
#                      encoding = "UTF-8")



#quot
#partidos = c("PSOE","C's","UPYD","PP","PODEMOS","UP") 
#hasht
#partidos = c("C's","PP","PSOE","UPYD","UP","PODEMOS") 
# partidos = c("PP","UPYD","PODEMOS","UP","C's","PSOE") 
#retweet
# partidos = c("CUP","JxSi","PSC","Catsiq","C's","PP") 
# quote
# partidos = c("C's","PSC","JxSi","Catsiq","CUP","PP")
#  partidos = c("PODEMOS","PP","PSOE","UPYD","UP","C's") 
# 
# 
# retweets = data.frame("partido"=partidos,"freq"=count(comunidades$Modularity.Class)$freq)

retweets = read.csv(sep = ",",
                    "cis.csv",
                    encoding = "UTF-8")

retweets$prob = get.prob(as.numeric(retweets$followers_candidato),
                         as.numeric(retweets$followers_candidato))

retweets$prob6 = get.prob(as.numeric(retweets$sentiment),
                         as.numeric(retweets$sentiment))

retweets$prob2 = get.prob(as.numeric(retweets$menciones),
                         as.numeric(retweets$menciones))

retweets$prob4 = get.prob(as.numeric(retweets$followers),
                          as.numeric(retweets$followers))


retweets$prob3 = get.prob(as.numeric(retweets$menciones),
                          as.numeric(retweets$menciones))

retweets$prob = get.prob(as.numeric(retweets$votos),
                          as.numeric(retweets$votos))


# retweets$prob3 = (retweets$prob2 + retweets$prob4 +retweets$prob6 ) /3


# retweets = count(retweets)

retweets$prob = get.prob(retweets$freq,
                         retweets$freq)

retweets$prob5 = get.prob(retweets$sentiment,
                         retweets$sentiment)

resultados.votaciones$prob = get.prob(resultados.votaciones$votos, resultados.votaciones$votos)


comparacion = merge(resultados.votaciones, retweets, by='partido',
                    suffixes=c('.votos', '.retweets'))

mae.val = mae(comparacion$prob.votos,comparacion$prob.retweets)
cor.val = cor(comparacion$prob.votos,comparacion$prob.retweets, method="pearson")


mytable <- cbind(op=c("mae","cor"),
                 data.frame("valores" = c(mae.val,cor.val)))


g = ggplot( comparacion, aes(x=prob.retweets, y=prob.votos) ) +
  geom_point( aes(color=partido), size=5 ) +
  theme_bw() + theme( legend.position=c(0.1, 0.78) )

g = g + geom_smooth(aes(group=1), se=F, method="lm") + scale_y_continuous(labels = comma)

g= g + xlab("Encuesta CIS Octubre 2015")
g= g + ylab("Votos")
# g = g + annotation_custom(tableGrob(mytable), xmin=0.2, ymin=0.05, ymax=0.05)

library(psychometric)
CIr(r=-.43, n =6, level = .90)
