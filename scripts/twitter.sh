
cp twitterdb.db temp.db


echo "Making hashtag list csv";
sqlite3 -csv temp.db "SELECT replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( lower(hashtag), 'á','a'), 'Á','a'), 'à','a'), 'À','a'), 'è','e'), 'é','e'), 'È','e'),'É','e'), 'Ì','i'),'í','i'),'Í','i'),'ì','i'),'ó','o') ,'ò','o'),'Ó','o') ,'Ò','o') ,'ú','u'), 'ù','u') ,'Ú','u'), 'Ù','u') as h, count(distinct(tweet_id)) as count from hashtags, tweets where tweet_id=tweets.id group by h order by count desc;" > resources/csv/hashtags_list.csv

hashtags=$(cut -d',' -f1 resources/csv/hashtags_list.csv | head -10 )


for hashtag in $hashtags
do
	sqlite3 -csv -header temp.db "SELECT text from tweets, hashtags where replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( lower(hashtag), 'á','a'), 'Á','a'), 'à','a'), 'À','a'), 'è','e'), 'é','e'), 'È','e'),'É','e'), 'Ì','i'),'í','i'),'Í','i'),'ì','i'),'ó','o') ,'ò','o'),'Ó','o') ,'Ò','o') ,'ú','u'), 'ù','u') ,'Ú','u'), 'Ù','u') like '$hashtag' and tweet_id=tweets.id;"  > resources/csv/hashtags/hashtags_list_$hashtag.csv

done

echo "Making tweet text csv";
sqlite3 -header -csv temp.db "SELECT screen_name, text from tweets,users where user_id=users.id;" > resources/csv/tweets_out.csv


echo "Making retweet graph csv";
sqlite3 -header -csv -separator '(a@a)' temp.db "select source, users.screen_name as target from users, tweets, (select users.screen_name as source, retweet_id as r from tweets, users where retweet_id<>-1 and users.id=user_id) where r=tweets.id and user_id=users.id;" > resources/retweet_out.csv

echo "Making hashtag graph csv";

sqlite3 -csv -separator '(a@a)' temp.db "select users.screen_name as source,  '#:' || replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( lower(hashtag), 'á','a'), 'Á','a'), 'à','a'), 'À','a'), 'è','e'), 'é','e'), 'È','e'),'É','e'), 'Ì','i'),'í','i'),'Í','i'),'ì','i'),'ó','o') ,'ò','o'),'Ó','o') ,'Ò','o') ,'ú','u'), 'ù','u') ,'Ú','u'), 'Ù','u') as target from hashtags,tweets,users where tweet_id=tweets.id and user_id=users.id and target not like '#:election2016' and target not like 'election2016';" > resources/hashtags_out.csv

echo "Making quote graph csv";
sqlite3 -header -csv -separator '(a@a)' temp.db "select source, users.screen_name as target from users, (select users.screen_name as source, quoted_user_id as q from tweets, users where quoted_user_id<>-1 and users.id=user_id) where q=users.id;" > resources/quote_out.csv

#echo "quote graph $(grep -c $'\t' resources/quote_out.csv)";
#echo "retweet graph $(grep -c $'\t' resources/retweet_out.csv)";
#echo "hashtag graph $(grep -c $'\t' resources/hashtags_out.csv)";

echo "Cleaning temp files"
#sed s/'\t'/' '/g out.csv > temp.csv
sed s/'\"'//g resources/retweet_out.csv | sed s/'(a@a)'/'\t'/g  > resources/csv/process_retweet_out.csv 
sed s/'\"'//g resources/hashtags_out.csv | sed s/'(a@a)'/'\t'/g  > resources/csv/process_hashtag_out.csv 
sed s/'\"'//g resources/quote_out.csv | sed s/'(a@a)'/'\t'/g  > resources/csv/process_quote_out.csv 

rm -f temp.db
rm -f resources/retweet_out.csv
rm -f resources/hashtags_out.csv
rm -f resources/quote_out.csv
