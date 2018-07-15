def one():
  #https://www.safaribooksonline.com/library/view/deep-learning-for/9781484236857/A461351_1_En_1_Chapter.html
  import nltk
  #sent_ = "Great Agamemnon! glorious king of men!"
  sent_ = "You can tokenize a given sentence into individual words, as follows"
  nltk.download('punkt')
  nltk.download('wordnet')
  tokens_ = nltk.word_tokenize(sent_)
  print(sent_)
  print(tokens_)
  import itertools
  stemmer = nltk.stem.PorterStemmer()
  lemmatizer = nltk.stem.WordNetLemmatizer()
  for token in tokens_:
    stem = stemmer.stem(token)
    lemm = lemmatizer.lemmatize(token)
    print("##### '{}' stem:'{}' lem:'{}' definition:".format(token, stem, lemm))
    for synnet_ in itertools.islice(nltk.corpus.wordnet.synsets(token), 0, 3):
      print(">>> {}".format(synnet_.definition()))

if __name__ == '__main__':
  #execute the last function declared
  fun_to_execute = None
  for member_name in dir():
    member = eval(member_name)
    if not member_name.startswith("__"):
      if hasattr(member, '__code__'):
        if hasattr(member.__code__, 'co_firstlineno'):
          if fun_to_execute:
            if member.__code__.co_firstlineno > fun_to_execute.__code__.co_firstlineno:
              fun_to_execute = member
          else:
            fun_to_execute = member
  if fun_to_execute:
    print("##### executing {}".format(fun_to_execute.__code__.co_name))
    fun_to_execute()
  else:
    print("no functions found")

