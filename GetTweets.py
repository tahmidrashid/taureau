import datetime
import timedelta
import time
import tweepy
import numpy as np
import json
import string
import sys


# Returns a string of the second word on the first line where flag is the first word
# Used for reading in keys for API from Keys file
def read(f, flag):
	for line in f:
		words = line.split()
		if words[0] == flag:
			return words[1]
	return ""


def authenticate():

	key_file = open("Keys.dat", 'r')
	consumer_key = read(key_file, "consumer_key")
	consumer_secret = read(key_file, "consumer_secret")
	access_token = read(key_file, "access_token")
	access_token_secret = read(key_file, "access_token_secret")
	key_file.close()

	auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
	auth.set_access_token(access_token, access_token_secret)

	return tweepy.API(auth)


def process_text(text):
	ret = ""
	for c in text:
		if c == "\"":
			ret = ret + "\\\""
		elif c in string.printable[:95]:
			ret = ret + c
	return ret
	#wanted = string.printable[:63] + string.printable[65:94]
	#return "".join(c for c in text if c in wanted)


def to_json(tweet):
	ret = "{"
	ret = ret + "\"text\": \"" + process_text(tweet.text) + "\", "
	ret = ret + "\"from_user\": \"" + tweet.user.screen_name + "\", "
	ret = ret + "\"from_user_id\": " + str(tweet.user.id) + ", "
	if str(tweet.geo) == "None":
		ret = ret + "\"geo\": null, "
	else:
		ret = ret + "\"geo\": " + str(tweet.geo) + ", "
	ret = ret + "\"id\": " + str(tweet.id) + ", "
	ret = ret + "\"iso_language_code\": \"" + tweet.metadata["iso_language_code"] + "\", "
	ret = ret + "\"from_user_id_str\": \"" + tweet.user.id_str + "\", "
	ret = ret + "\"created_at\": \"" + str(tweet.created_at) + "\", "
	ret = ret + "\"source\": \"" + tweet.source + "\", "
	ret = ret + "\"id_str\": \"" + tweet.id_str + "\", "
	ret = ret + "\"from_user_name\": \"" + tweet.user.name + "\", "
	ret = ret + "\"metadata\": {\"result_type\": \"" + tweet.metadata["result_type"] + "\"}}\n"
	return ret


def print_to_file(search_results, company, date):
	filename = company + "-" + str(date.year) + "-" + str(date.month) + "-" + str(date.day) + ".json"
	output_file = open(filename, 'w', encoding = "utf-8")
	for tweet in search_results:
		output_file.write(to_json(tweet))
	output_file.close()


def collect_tweets(api, company, start, end):

	max_count = 10000

	date = start
	while not (date.day == end.day + 1):
		
		if company == "Tmobile":
			search = "T-mobile OR Tmobile OR \"T mobile\"" + " since:" + str(date.year) + "-" + str(date.month) + "-" + str(date.day) + " until:" + str(date.year) + "-" + str(date.month) + "-" + str(date.day+1)
		elif company == "Intel":
			search = "@" + company + " since:" + str(date.year) + "-" + str(date.month) + "-" + str(date.day) + " until:" + str(date.year) + "-" + str(date.month) + "-" + str(date.day+1)
		else:
			search = "#" + company + " since:" + str(date.year) + "-" + str(date.month) + "-" + str(date.day) + " until:" + str(date.year) + "-" + str(date.month) + "-" + str(date.day+1)

		all_results = []
		search_results = tweepy.Cursor(api.search, q = search, lang = "en", result_type = "recent", count = max_count).items(max_count)
		while True:
			try:
				tweet = search_results.next()
				all_results.append(tweet)
			except tweepy.TweepError:
				print("\nRate limit reached: sleeping for 15 minutes")
				time.sleep(60 * 15)
				print("Resuming\n")
				continue
			except StopIteration:
				break

		print_to_file(all_results, company, date)
		
		date = date + datetime.timedelta(days = 1)


def assign_args(argv):

	if len(sys.argv) != 5:
		raise ValueError

	return (int(argv[1]), int(argv[2]), int(argv[3]), int(argv[4]))


def main(argv):

	(start_month, start_date, end_month, end_date) = assign_args(argv)

	api = authenticate()

	companies = ["Apple", "Google", "Tesla", "Facebook", "Intel", "Tmobile", "Amazon"]

	for company in companies:
		
		start = datetime.datetime(2020, start_month, start_date)
		end = datetime.datetime(2020, end_month, end_date)
		
		collect_tweets(api, company, start = start, end = end)


if __name__ == "__main__":
	main(sys.argv)











































