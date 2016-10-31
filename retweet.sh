
cp twitterdb.db temp.db

sqlite3 -header -csv -separator '(a@a)' temp.db "select source, users.screen_name as target from users, tweets, (select users.screen_name as source, retweet_id as r from tweets, users where retweet_id<>-1 and users.id=user_id) where r=tweets.id and user_id=users.id;" > retweet_out.csv

sqlite3 -header -csv temp.db "SELECT '#' || replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( lower(hashtag), 'á','a'), 'Á','a'), 'à','a'), 'À','a'), 'è','e'), 'é','e'), 'È','e'),'É','e'), 'Ì','i'),'í','i'),'Í','i'),'ì','i'),'ó','o') ,'ò','o'),'Ó','o') ,'Ò','o') ,'ú','u'), 'ù','u') ,'Ú','u'), 'Ù','u') as h, count(distinct(tweet_id)) as count from hashtags, tweets where tweet_id=tweets.id group by h order by count desc;" > hashtags_out.csv

#sed s/'\t'/' '/g out.csv > temp.csv
sed s/'\"'//g retweet_out.csv | sed s/'(a@a)'/'\t'/g  > process_retweet_out.csv 

rm -f temp.db
#rm -f temp.csv