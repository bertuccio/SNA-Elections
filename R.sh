#!/bin/bash

for i in $*
do
	if [ "$i" == "wordcloud" ]
	then
		./scripts/wordcloud.sh
	fi
done

