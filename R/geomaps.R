#Install
# install.packages("sp")
# apt-get install libgdal1-dev libproj-dev
# install.packages("rgdal")
# install.packages("OpenStreetMap")




#Load
library (sp)
library (rgdal)
library (OpenStreetMap)
library(RSQLite)
setwd("/home/pinwi/workspace/SNAElections")
# connect to the sqlite file
con = dbConnect(drv=RSQLite::SQLite(), dbname="twitterdb.db")

# get a list of all tables
# alltables = dbListTables(con)
# dbListFields(con, "Tweets")

# print(alltables)


ptm <- proc.time()
geo_tweets = dbGetQuery( con,'select users.screen_name, geo_lat as lat, geo_lng as lon from tweets, users where geo_lat<>-1 and user_id=users.id')
proc.time() - ptm

# make up some points 
pts.euref <- SpatialPoints(cbind(lon=geo_tweets$lon,lat=geo_tweets$lat))
# proj4string(pts.euref) <- CRS("+proj=utm +zone=35 +ellps=GRS80 +units=m +no_defs")

# reproject to geographic coordinates
# pts.wgs84<- spTransform(pts.euref, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# retrieve basemap
osm <- openmap (c(bbox(pts.euref)[2,2] + 1, bbox(pts.euref)[1,1] - 1), c(bbox(pts.euref)[2,1] - 1, bbox(pts.euref)[1,2] + 1))

# reproject basemap
# osm.euref <- openproj (osm, proj4string(pts.euref))

#plot
plot (osm)
# plot (pts.euref, add=T, pch=1050)


# make up some points 
pts.euref <- SpatialPoints(cbind(lon = sample (300000:500000, 100),lat = sample (6800000:7000000,100)))
proj4string(pts.euref) <- CRS("+proj=utm +zone=35 +ellps=GRS80 +units=m +no_defs")

# reproject to geographic coordinates
# pts.wgs84<- spTransform(pts.euref, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

# retrieve basemap
osm <- openmap (c(bbox(pts.euref)[2,2] + 1, bbox(pts.euref)[1,1] - 1), c(bbox(pts.euref)[2,1] - 1, bbox(pts.euref)[1,2] + 1))

# reproject basemap
# osm.euref <- openproj (osm, proj4string(pts.euref))

#plot
plot (osm)
plot (pts.euref, add=T, pch=20)

setwd("/home/pinwi/workspace/SNAElections")
# connect to the sqlite file
con = dbConnect(drv=RSQLite::SQLite(), dbname="twitterdb.db")
# make up some points 
# pts.euref <- SpatialPoints(cbind(lon = sample (300000:500000, 100),lat = sample (6800000:7000000,100)))
ptm <- proc.time()
geo_tweets = dbGetQuery( con,'select users.screen_name, geo_lat as lat, geo_lng as lon from tweets, users where geo_lat<>-1 and user_id=users.id')
proc.time() - ptm

# make up some points 
pts.euref <- SpatialPoints(cbind(lon=geo_tweets$lon,lat=geo_tweets$lat,data=geo_tweets))

proj4string(pts.euref) <- CRS("+proj=longlat")

# reproject to geographic coordinates
pts.wgs84<- spTransform(pts.euref, CRS("+proj=longlat"))

# retrieve basemap
osm <- openmap (c(bbox(pts.wgs84)[2,2] + 1, bbox(pts.wgs84)[1,1] - 1), c(bbox(pts.wgs84)[2,1] - 1, bbox(pts.wgs84)[1,2] + 1))

# reproject basemap
osm.euref <- openproj (osm, proj4string(pts.euref))

cols<-brewer.pal(n=length(unique(geo_tweets$screen_name)),name="Set1")

#plot
plot (osm.euref)
plot (pts.euref, add=T, pch=20, col=factor(geo_tweets$screen_name))


set.seed(1331)
pts = cbind(1:5, 1:5)
dimnames(pts)[[1]] = letters[1:5]
df = data.frame(a = 1:5)
row.names(df) = letters[5:1]

library(sp)
library(ggplot2)
options(warn=1) # show warnings where they occur
SpatialPointsDataFrame(cbind(geo_tweets$lat, geo_tweets$lon),geo_tweets) # warn
SpatialPointsDataFrame(pts, df, match.ID = TRUE) # don't warn
SpatialPointsDataFrame(pts, df, match.ID = FALSE) # don't warn
df$m = letters[5:1]
SpatialPointsDataFrame(pts, df, match.ID = "m") # don't warn

dimnames(pts)[[1]] = letters[5:1]
pts.df  <- SpatialPointsDataFrame(cbind(geo_tweets$lon, geo_tweets$lat), geo_tweets) # don't warn: ID matching doe
proj4string(pts.euref) <- CRS("+proj=longlat")

# reproject to geographic coordinates
pts.wgs84<- spTransform(pts.euref, CRS("+proj=longlat"))

# retrieve basemap
osm <- openmap (c(bbox(pts.wgs84)[2,2] + 1, bbox(pts.wgs84)[1,1] - 1), c(bbox(pts.wgs84)[2,1] - 1, bbox(pts.wgs84)[1,2] + 1))

osm.euref <- openproj (osm, proj4string(pts.euref))
ggplot(osm.euref)
plot ()

plot (pts.df, add=T, pch=20, col=factor(pts.df$screen_name))
