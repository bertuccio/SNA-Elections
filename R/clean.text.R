clean.text = function(txtclean)
{
  # remove retweets
  txtclean = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", " ", txtclean)
  # remove @quotes
  txtclean = gsub("@\\w+", " ", txtclean)
  # remove hashtags
  txtclean = gsub("#\\S+", " ", txtclean)
  # remove links
  txtclean = gsub("htt\\S+", " ", txtclean)
  # remove \n
  txtclean = gsub("\\n", " ", txtclean,fixed = TRUE)
  # remove \r
  txtclean = gsub("\\r", " ", txtclean,fixed = TRUE)
  # remove \t
  txtclean = gsub("\\t", " ", txtclean,fixed = TRUE)
  txtclean = gsub("[^[:alnum:][:space:]']", " ", txtclean)
  # remove numbers
  txtclean = gsub("[[:digit:]]", " ", txtclean)
  
  # remove blank spaces at the beginning
  txtclean = gsub("^ ", "", txtclean)
  # remove blank spaces at the end
  txtclean = gsub(" $", "", txtclean)
  
  return(txtclean)
}