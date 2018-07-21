def first():
  import re
  words = ['my', 'email', 'is', 'classified']
  regex = '|'.join(words)
  print("regex applied: {}".format(regex))
  multi_line = re.M
  found = re.findall(regex, 'this email lenght is much to long', multi_line)
  print(found)

def second():
  import urllib3
  from bs4 import BeautifulSoup
  pool_object = urllib3.PoolManager()
  url = 'http://www.gutenberg.org/files/2554/2554-h/2554-h.htm#link2HCH0008'
  response = pool_object.request('GET', url)
  print(dir(response))
  txt = BeautifulSoup(response.data[:100])
  print(txt)

def get_this():
  with open(__file__, 'r') as this:
    text = ''.join(this.readlines())
  return text 

def remove_stopwords():
  import nltk
  from nltk import word_tokenize
  nltk.download('stopwords')
  from nltk.corpus import stopwords
  text = get_this()
  no_stopwords = [w for w in word_tokenize(text) 
                  if not w in set(stopwords.words('english'))]
  print(no_stopwords)
  return no_stopwords

def stem():
  '''
  https://tartarus.org/martin/PorterStemmer/
  The Porter stemmer removes common morphological and inflexional endings from words in English. Its main use is as part of a term normalisation process.
  '''
  from nltk.stem import PorterStemmer
  stem = PorterStemmer()
  text = get_this()
  result = [stem.stem(w) for w in text]
  print(result)

def counter_vectorization():
  from sklearn.feature_extraction.text import CountVectorizer
  with open(__file__, 'r') as this:
    text = this.readlines()
  cv = CountVectorizer()
  cv_fit = cv.fit_transform(text)
  print(cv.get_feature_names())
  print(cv_fit.toarray())

def tfidf():
  from sklearn.feature_extraction.text import TfidfVectorizer
  with open(__file__, 'r') as this:
    text = this.readlines()
  print(TfidfVectorizer().fit_transform(text).todense())

if __name__ == '__main__':
  import argparse, re
  parser = argparse.ArgumentParser()
  with open(__file__, 'r') as this:
    parser.add_argument("fun", choices=[re.split("[ (]", line)[1] for line in this if line.startswith("def")])
  args = parser.parse_args()
  print("################ executing {}".format(args.fun))
  _ = eval(args.fun)()
