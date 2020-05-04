import json
import datetime
import timedelta
import sys
import random
import operator
import csv


# Accepts two strings a and b
# Returns a float of the Jaccard distance between the two sets as computed from the
# formula given in the assignment description
def jaccard_distance(a, b):
	a = remove_tags(a)
	a = process_text(a)
	b = remove_tags(b)
	b = process_text(b)
	u = union(a,b)
	i = intersect(a,b)
	if len(u) == 0:
		return 1.0
	return 1.0 - float(len(i)) / float(len(u))


# Accepts a string text
# Returns the string without any "RT" or "@handle" tags or links, words beginning with "http"
# Also removes any hashtag characters but keeps the characters after the # symbol
def remove_tags(text):
	words = text.split()
	ret = ""
	for word in words:
		if word[0] == '#':
			ret = ret + word[1:] + " "
		elif not ((word[0:2] == "RT") | (word[0] == '@') | (word[0:4] == "http")):
			ret = ret + word + " "
	return ret


# Accepts a string s
# Returns the string with all punctuation removed and with all characters converted
# to lower case
def process_text(s):
	return ''.join(ch.lower() for ch in s if ((ch.isalnum()) | (ch == " ")))


# Accepts two strings a and b
# Returns a list of strings that represents the union of the two sets, a list of
# all words that appear in either set
def union(a,b):
	a = a.split()
	b = b.split()
	a = set(a)
	b = set(b)
	return a | b


# Accepts two strings a and b
# Returns a list of strings that represents the intersection of the two sets, a list
# of all words that appear in both sets
def intersect(a,b):
	a = a.split()
	b = b.split()
	a = set(a)
	b = set(b)
	return a & b


# Accepts a file f
# Returns each line of the file f as a string, excluding newlines and any commas
# at the end of the line
# Used for reading in the list of twitter IDs in InitialSeeds.txt
def get_ids(f):
	nums = []
	for line in f:
		line = line.rstrip()
		if line[-1] == ",":
			nums.append(int(line[:-1]))
		else:
			nums.append(int(line))
	return nums


def read_tweets(filename):
	tweets = []
	with open(filename, 'r') as file:
		csvreader = csv.reader(file, delimiter=",", quotechar='"')
		i = 1
		for line in csvreader:
			tweets.append(line[2])

	return tweets[1:]


# Goes through the given file line by line and returns a list of tuples, the first element storing the date
# in a date object, the second element storing the sentiment score as a double
def parse_predictions(filename):
	dates = []
	first_line = True
	with open(filename, 'r') as file:
		for line in file:
			if first_line:
				first_line = False
				continue
			line = line.split()
			date = line[0].split("-")
			year = date[0]
			month = date[1]
			day = date[2]
			year = int("".join(ch for ch in year if ch.isalnum()))
			month = int("".join(ch for ch in month if ch.isalnum()))
			day = int("".join(ch for ch in day if ch.isalnum()))
			dates.append((datetime.datetime(year, month, day), float(line[1])))
	return dates


# Accepts the name of the company and a threshold for magnitude of movement
# Returns all dates for which the actual corrected stock price movement for that company was greater
# than the threshold
def get_dates(company, threshold):

	dates = []
	filename = company + "-predict.txt"
	predictions = parse_predictions(filename)
	for date in predictions:
		if abs(date[1]) > threshold:
			dates.append((date[0], date[1]))

	return dates


def get_tweets_dict(tweets_text):

	dic = dict()

	for tweet in tweets_text:
		if tweet in dic:
			dic[tweet] = dic[tweet] + 1
		else:
			dic[tweet] = 1

	return dic


# Accepts the name of the company and a list of dates
# For each date, appends to the output the text of tweets from the 5 largest clusters
# Returns the output as a string
def get_output(company, dates, num_tweets):

	output = ""

	for date in dates:
		
		filename = "Tesla_csv/" + company + "-" + str(date[0].year) + "-" + str(date[0].month) + "-" + str(date[0].day) + ".csv"
		tweets = read_tweets(filename)

		tweets_text = []
		for t in tweets:
			r = remove_tags(t)
			if len(r) > 0:
				tweets_text.append(r)

		tweets_dict = get_tweets_dict(tweets_text)

		sorted_tweets_dict = sorted(tweets_dict.items(), key = operator.itemgetter(1), reverse = True)

		output = output + company + " on " + str(date[0].year) + "-" + str(date[0].month) + "-" + str(date[0].day)  + "\n"
		output = output + "Predicted movement of " + str(date[1]) + "\n"
		output = output + "15 Most Common Topics of Conversation\n"
		for i in range(num_tweets):
			output = output + str(sorted_tweets_dict[i][1]) + "x: " + sorted_tweets_dict[i][0] + "\n"
		output = output + "\n\n\n"

	return output


def main(argv):

	companies = ["Tesla"] #["Apple", "Google", "Tesla", "Facebook", "Intel", "Tmobile", "Amazon"]
	if len(argv) == 3:
		threshold = float(argv[1])
		num_tweets = int(argv[2])
	else:
		threshold = 0.1
		num_tweets = 15
	output = ""

	for company in companies:

		dates = get_dates(company, threshold)

		output = output + get_output(company, dates, num_tweets)

	with open("SignificantEvents.txt", 'w') as file:
		file.write(output)


if __name__ == "__main__":
	main(sys.argv)












































