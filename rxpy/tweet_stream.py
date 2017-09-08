#https://marcobonzanini.com/2015/03/02/mining-twitter-data-with-python-part-1/
#https://github.com/tweepy/tweepy/blob/master/examples/streaming.py
import tweepy, os, tweepy.streaming, json, time
from rx import Observable

def observe_tweets(observer):
     
  class TweeterListener(tweepy.streaming.StreamListener):
  
    def __init__(self, time_window_in_seconds, on_data_fun, on_error_fun):
      self.queue = []
      self.time_window_in_seconds = time_window_in_seconds
      self.start_time = time.perf_counter()
      self.on_data_fun = on_data_fun
      self.on_error_fun = on_error_fun
  
    def on_data(self, data):
      json_data = json.loads(data)
      if "text" in json_data:
        tweet_text = json_data["text"]
        self.queue.append(tweet_text)
  
      time_elapsed = time.perf_counter() - self.start_time
      if time_elapsed >= self.time_window_in_seconds:
        for tweet in self.queue:
          self.on_data_fun(tweet)
        self.start_time = time.perf_counter()
        self.queue = []
  
      return True
    
    def on_error(self, status): 
      self.on_error_fun(status) 
  
  consumer_key = os.environ["TWITTER_CONSUMER_KEY"]
  consumer_secret = os.environ["TWITTER_CONSUMER_SECRET"]
  access_token = os.environ["TWITTER_ACCESS_TOKEN"]
  access_secret = os.environ["TWITTER_ACCESS_SECRET"]
  auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
  auth.set_access_token(access_token, access_secret)
  
  l = TweeterListener(0, observer.on_next, observer.on_error)
  stream = tweepy.Stream(auth, l)
  stream.filter(track=['trump'])
 
Observable.create(observe_tweets).share().subscribe(print)

input("press any key to exit")
