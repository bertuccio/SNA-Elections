#!/bin/bash

for i in $*
do
	if [ "$i" == "wordcloud" ]
	then
		./scripts/wordcloud.sh
	fi
	if [ "$i" == "sentiment" ]
	then
		./scripts/sent.sh
	fi	
done

