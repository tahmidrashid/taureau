#Taureau: A Stock Market Movement Inference Framework Based on Twitter Sentiment Analysis

Joshua Johnson, Nick Milikich, & Md Tahmid Rashid

CSE 60437 Social Sensing & Cyber-Physical Systems

May 4, 2020


This project implements Taureau, a framework for inferring stock market movement from Twitter sentiment analysis.
The Taureau framework consists of four parts:
- Tweet collection: Using the twitter API, tweets are collected that match a simple search criteria for a given company name and organized by date of posting.
- Sentiment analysis: The Taureau framework leverages the TextBlob sentiment analysis engine that uses an ensemble of different statistical approaches to generate the opinion and mood expression with the tweets. In particular, Taureau transforms the input texts using the Word2vec model and incorporates an opinion mining technique based on an ensemble of the Naive Bayes and Random Forest Classifiers to assess and quantify the mood of the users embedded within the tweets. For each tweet, the TextBlob engine generates two numeric outputs: i) the Subjectivity and ii) the Polarity. The Polarity, also known as orientation is the emotion expressed in the sentence. The Polarity score ranges on a scale of $[-1,1]$ can be categorized as positive (i.e. closer to $1$), negative (i.e. closer to $-1$), or neutral (i.e. closer to $0$). Subjectivity, on the other hand is a measure of text as a fact or opinion. The metric is helpful in determining whether a text is an explanatory article based on facts (objective) or just an expression of a person's feeling or attitude about a company (subjective). The Subjectivity score ranges on a scale of $[0,1]$ with $0$ indicating least subjective and $1$ indicating most subjective tweets.
- Stock movement analysis: The stock price of each company is scraped from Yahoo finance, converted to a daily percent difference, and corrected by subtracting the Dow-Jones percent movement. The correlation between stock movement and sentiment is calculated, and a model is trained and tested to predict stock movement from sentiment scores. Predicted stock movement from the model is written to ##-predict.txt, where ## is the name of the company, with each line including the date, the predicted movement in the form of a decimal, and the resulting recommendation (-1 for sell, 0 for hold, 1 for buy). Each aspect of the analysis is visualized as well.
- Tweet reporting: Using the predictions from stock movement analysis, any dates with large predicted movements (by default >0.1, but can be changed) are identified, the tweets about that company from those days analyzed, and the 15 (again, by default, but can be changed) most-repeated tweets reported, to give an idea of topics of conversation from that day that might have generated that extreme prediction.

To run the analysis done in our project (for Tesla for the period of March-April 2020), follow the instructions for each task:
- Tweet collection: Be sure that Keys.dat (included in this submission) is included in the same directory (can be edited for a different Twitter API credentials). Run GetTweets.py using four command line arguments specifying the beginning and end dates to be collected, inclusive, in the form of beginning month/date, end month/date. For example, to collect from March 6 to March 11, 2020, one would execute 'python3 GetTweets.py 3 6 3 11'.
- Sentiment analysis: Be sure that the steps for tweet collection have been followed and that the tweet json files are organized as desired. Run GenerateSentiment.py, editing the appropriate 'inline' argument on line 21 to give the file name for the desired company and date. The printed scores can be collected in an excel file SentimentScoresAverage.xlsx (included in this submission).
- Stock movement analysis: Be sure that the steps for sentiment analysis have been followed and that SentimentScoresAverage.xlsx is in the same directory. Run StockAnalysis.R; Tesla-predict.txt will be generated as a result.
- Tweet reporting: Be sure that the steps for stock movement analysis have been followed and that Tesla-predict.txt is in the same directory. Run TweetReporting.py; command line arguments can be passed to this program, with the first a floating point number specifying the threshold for movement (ex. 0.1), and the second an integer specifying the number of tweets to be reported for each day (ex. 15). If either argument is not provided then the defaults will be used. SignificantEvents.txt will be generated as a result.

This code was developed and tested using Python version 3.8.1.
