from rx import Observable, Observer

def class_one():
  
  letters = Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])
  
  class MySubscriber(Observer):
  
    def on_next(self, value):
      print(value)
  
    def on_completed(self):
      print("done")
  
    def on_error(self, error):
      print(error)
  
  letters.subscribe(MySubscriber())

def class_two():
  
  letters = Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])

  letters.subscribe(on_next=lambda s: print(s),
                    on_completed= lambda: print("====done===="),
                    on_error=lambda e: print(e))

def class_three():
  letters = Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"]) \
                      .map( lambda s: ( s, len(s) ) ) \
                      .filter(lambda l: l[1] >= 5) \
                      .subscribe(on_next=lambda s: print(s[0]))

def class_four():
  Observable.range(1, 10).subscribe(on_next=lambda s: print(s))

def class_five():
  Observable.just("Hello world").subscribe(on_next=lambda s: print(s))

def class_six():
  def push_numbers(observer):
    observer.on_next(300)
    observer.on_next(500)
    observer.on_next(700)
    observer.on_completed()

  Observable.create(push_numbers).subscribe(print)

def class_seven():
  import time
  disposable = Observable.interval(1000) \
                         .map(lambda x: "{0} Missisipi".format(x)) \
                         .subscribe(print)
  time.sleep(5)
  disposable.dispose()
  input("press any key to exit")

def class_eight():
  Observable.from_(["one", "two", "three", "four", "five"])\
            .filter(lambda x: len(x) in [3,4])\
            .take(2)\
            .subscribe(print)
 
def class_nine():
  Observable.range(10, 100)\
            .take_while(lambda x: x < 20)\
            .subscribe(print)

def class_ten():
  Observable.range(10,100)\
            .distinct(lambda x: x % 5)\
            .subscribe(print)

def class_eleven():
  Observable.from_(["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"])\
            .map(lambda x: (x, len(x)))\
            .distinct_until_changed(lambda x: x[1])\
            .map(lambda x: x[0])\
            .subscribe(print)
  
def class_twelve():
  Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"]) \
            .count() \
            .subscribe(print)

def class_thirteen():
  words = Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])
  Observable.from_([
             words.count(),
             words.map(lambda x: len(x)).sum(),
             words.map(lambda x: len(x)).average(),
             words.reduce(lambda x, y: x + y)]
             ).merge_all().subscribe(print)

def class_fourteen():
  Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])\
            .scan(lambda x, y: x + y)\
            .subscribe(print)
  
def class_fifthteen():
  words = Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])
  words.to_list().subscribe(print)
  words.to_dict(lambda x: x[0]).subscribe(print)

def class_sixteen():
  source1 = Observable.interval(1000).map(lambda i: "source 1 {0}".format(i))
  source2 = Observable.interval(500).map(lambda i: "source 2 {0}".format(i))
  source3 = Observable.interval(200).map(lambda i: "source 3 {0}".format(i))
  Observable.merge(source1, source2, source3).subscribe(print)
  input("press any key to finish")

def github_one():
  from rx.internal import extensionmethod

  @extensionmethod(Observable, alias="merp")
  def herp(self):
    return self.map(lambda x: (x, "herp"))

  Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])\
            .herp()\
            .merp()\
            .subscribe(print)

def github_two():
  from rx.internal import extensionmethod
  @extensionmethod(Observable)
  def duplicate(self, times=1):
    obs = self
    for replicant in range(0, times):
      obs = obs.merge(self)
    return obs

  Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])\
            .duplicate(3)\
            .subscribe(print)
    
def class_seventeen():
  Observable.from_(["12/33/23/44/21","34/3/333/21/34", "4/444/34/0099"])\
            .map(lambda s: Observable.from_(s.split("/")))\
            .merge_all()\
            .map(lambda s: int(s))\
            .subscribe(print)

def class_eightteen():
  Observable.from_(["12/33/23/44/21","34/3/333/21/34", "4/444/34/0099"])\
            .flat_map(lambda s: Observable.from_(s.split("/")))\
            .map(lambda s: int(s))\
            .subscribe(print)

def class_nineteen():
  letters1 = Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])
  letters2 = Observable.from_iterable(["Zeta", "Exo", "Flota", "Delta"])
  Observable.concat(letters1, letters2)\
            .subscribe(print)

def class_twenty():
  Observable.from_(["12/33/23/44/21","34/3/333/21/34", "4/444/34/0099"])\
            .map(lambda s: Observable.from_(s.split("/")))\
            .concat_all()\
            .map(lambda s: int(s))\
            .subscribe(print)

def class_twentyone():
  letters = Observable.from_(["a", "b", "c", "d", "e", "f"])
  numbers = Observable.range(1, 5)
  Observable.zip(letters, numbers, lambda l, n: "{} <===> {}".format(l, n)).subscribe(print)


def class_twentytwo():
  letters = Observable.from_(["a", "b", "c", "d", "e", "f"])
  numbers = Observable.range(1, 5)
  letters.zip(numbers, lambda l, n: "{} <===> {}".format(l, n)).subscribe(print)

def class_twentythree():
  Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])\
            .group_by(lambda s: len(s))\
            .flat_map(lambda g: g.to_list())\
            .subscribe(print)

def class_twentyfour():
  Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])\
            .group_by(lambda s: len(s))\
            .flat_map(lambda g: g.count().map(lambda x: (g.key, x)))\
            .to_dict(lambda t: t[0], lambda t: t[1])\
            .subscribe(print)

def class_twentyfive():
  import requests
  text_request = requests.get("http://www.gutenberg.org/cache/epub/55506/pg55506.txt")
  if text_request.ok == False:
    print("request failed: {}".format(text_request.reason))
    print("{}".format(text_request.url))
    return

  from tempfile import NamedTemporaryFile
  temp = NamedTemporaryFile()
  temp.file.write(text_reqiest.content)
  temp.file.seek(0)
  # do something with the file 

  Observable.from_(["a", "b", "c", "d", "e", "f"])
  numbers = Observable.range(1, 5)
  Observable.zip(letters, numbers, lambda l, n: "{} <===> {}".format(l, n)).subscribe(print)


def class_twentytwo():
  letters = Observable.from_(["a", "b", "c", "d", "e", "f"])
  numbers = Observable.range(1, 5)
  letters.zip(numbers, lambda l, n: "{} <===> {}".format(l, n)).subscribe(print)

def class_twentythree():
  Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])\
            .group_by(lambda s: len(s))\
            .flat_map(lambda g: g.to_list())\
            .subscribe(print)

def class_twentyfour():
  Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])\
            .group_by(lambda s: len(s))\
            .flat_map(lambda g: g.count().map(lambda x: (g.key, x)))\
            .to_dict(lambda t: t[0], lambda t: t[1])\
            .subscribe(print)

def class_twentyfive():
  import requests
  from tempfile import NamedTemporaryFile
  def observe_file(url):
    text_request = requests.get(url)
    if text_request.ok == False:
      return Observable.throw("request failed: {}\n{}".format(text_request.reason,text_request.url))
  
    temp = NamedTemporaryFile(delete=False)
    temp.file.write(text_request.content)
    temp.close()
    return Observable.from_(open(temp.name))\
                     .map(lambda line: line.strip())\
                     .filter(lambda l: l != "")

  observe_file("http://www.gutenberg.org/cache/epub/55506/pg55506.txt").subscribe(print)
  input("please press any key to end")
  
def class_twentysix():
  from urllib.request import urlopen
  Observable.from_(urlopen("http://www.gutenberg.org/cache/epub/55506/pg55506.txt"))\
            .map(lambda l: l.decode("utf-8").strip())\
            .subscribe(print)

def class_twentyseven():
  from tempfile import NamedTemporaryFile
  import sqlite3
  from sqlalchemy import create_engine, text

  def get_words():
    with open("/etc/dictionaries-common/words") as dictionary: 
      for word in dictionary:
        yield word

  def get_insert_statements():
    insert_template = "insert into words values({},'{}')"
    for ordered_number, word in enumerate(get_words()):
      escaped_word = word.replace("'", "''")  
      yield insert_template.format(ordered_number, escaped_word)
 
  db = NamedTemporaryFile(delete=False)
  db.close()
  sqlite_con = sqlite3.connect(db.name)
  sqlite_con.execute("create table words(id int, word varchar)")
  for insert in get_insert_statements():
    sqlite_con.execute(insert)
  sqlite_con.commit()
  sqlite_con.close()

  alch_engine = create_engine("sqlite:///{}".format(db.name))
  alch_con = alch_engine.connect()

  def get_all_words(sqlite_path):
    stat = text("select * from words")
    return Observable.from_(alch_con.execute(stat).fetchall())
  
  def get_words(sqlite_path, ids):
    stat = text("select * from words where id = :id")
    return Observable.from_(ids)\
                     .flat_map(lambda id: Observable.from_(alch_con.execute(stat, id=id)))
  print('if hasattr(class_twentyseven, "next") == False:')
  if hasattr(class_twentyseven, "next") == False:
    print('get_all_words(db.name).subscribe(print)')
    get_all_words(db.name).subscribe(print)
    input("please press any key to finish")
  else:
    print('return lambda ids: get_words(db.name, ids)')
    return lambda ids: get_words(db.name, ids)

def class_twentyeight():
  class_twentyseven.__dict__["next"] = True
  class_twentyseven()([33, 44, 1]).subscribe(print)
  del class_twentyseven.next

def github_three():
  from rx.testing import marbles
  xs = Observable.from_marbles("a-b-c-|")
  print(xs.to_blocking().to_marbles())

def github_four():
  from rx.testing import marbles
  for marble_string in ["1-2-3-x-5", "1-2-3-4-5"]:
    print("marble_string {}".format(marble_string))
    xs = Observable.from_marbles(marble_string)
    print(xs.to_blocking().to_marbles())

def github_five():
  from rx.testing import marbles

  def test_marbles(marble_list, continuation_fun):
    obs = Observable.from_(marble_list)\
                    .map(lambda m: Observable.from_marbles(m))
    result = continuation_fun(obs).to_blocking()\
                                  .to_marbles()
    for marble in marble_list:
      print(marble)
    print(result)

  marble_list = ["1-2-3---4-5", "1-2-3-4-5"]
  print("concat_all") 
  test_marbles(marble_list, lambda o: o.concat_all())
  print("merge_all")
  test_marbles(marble_list, lambda o: o.merge_all())

def class_twentynine():
  import re
  def words_from_file(file_name):
    file = open(file_name)
    return Observable.from_(file)\
                     .map(lambda word: re.sub(r"\W", " ", word))\
                     .flat_map(lambda line: Observable.from_(line.split(" ")))\
                     .filter(lambda w: w != "")\
                     .map(lambda word: word.lower())

  def word_counter(file_name):
    return words_from_file(file_name).group_by(lambda x: x)\
                                     .flat_map(lambda o: o.count()\
                                                          .map(lambda c: (o.key, c)))\
                                     .to_dict(lambda t: t[0], lambda t: t[1])

  def go_go_go(interval):
    import os
    current_module_path = os.path.abspath(__file__)
  
    Observable.interval(interval)\
              .flat_map(lambda i: word_counter(current_module_path))\
              .distinct_until_changed()\
              .subscribe(print)

  go_go_go(3000)
  input("press to continue")

def class_thirty():
  import time
  print("==================")
  letters = Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])
  letters.subscribe(lambda x: print("first {}".format(x))) 
  time.sleep(2)
  letters.subscribe(lambda x: print("second {}".format(x))) 
  print("==================")

def class_thirtyone():
  # both have seperate interval counters
  import time
  obs = Observable.interval(1000).publish()
  obs.subscribe(lambda x: print("first {}".format(x))) 
  obs.connect()
  time.sleep(2)
  obs.subscribe(lambda x: print("second {}".format(x))) 
  input("press any key to continue")

def class_thirtytwo():
  # a single counter for all subscribers
  import time
  obs = Observable.interval(1000).publish().ref_count()
  obs.subscribe(lambda x: print("first {}".format(x))) 
  time.sleep(2)
  obs.subscribe(lambda x: print("second {}".format(x))) 
  input("press any key to continue\n")

def class_thirtythree():
  #same as Observable.interval(1000).publish().ref_count()
  import time
  obs = Observable.interval(1000).share()
  obs.publish(lambda x: print("first {}".format(x)))
  time.sleep(4)
  obs.publish(lambda x: print("second {}".format(x)))

def class_thirtyfour():
  #schedulers
  #ImmediateScheduler
  #NewThreadScheduler
  #ThreadPoolScheduler <--
  #TimeoutScheduler
  from rx.concurrency import ThreadPoolScheduler
  import time
  from threading import current_thread
  import multiprocessing
  import hashlib
  from rx.internal import extensionmethod 

  thread_count = multiprocessing.cpu_count() + 1
  pool_scheduler = ThreadPoolScheduler(thread_count)

  def intense_calculation(obs):
    for n in range(500000):
      _ = hashlib.sha256(str(n).encode()).hexdigest()
    #time.sleep(4)
    return obs 

  @extensionmethod(Observable)
  def apply_pool_scheduler(obs, boolean):
    if boolean == True:
      return obs.subscribe_on(pool_scheduler) 
    else:
      return obs 

  def do_example(schedule):
    start = time.perf_counter()
    letters = Observable.from_(["alpha", "Beta", "Gamma", "Delta", "Epsilon"])
    letters.map(intense_calculation)\
           .apply_pool_scheduler(schedule)\
           .subscribe(on_next=lambda s: print("process 1 {}".format(s))
                     ,on_error=lambda s: print("error {}".format(s))
                     ,on_completed=lambda: print("process 1 done, total time {}".format(time.perf_counter() - start))) 
   
    letters.map(intense_calculation)\
           .apply_pool_scheduler(schedule)\
           .subscribe(on_next=lambda s: print("process 2 {}".format(s))
                     ,on_error=lambda s: print("error {}".format(s))
                     ,on_completed=lambda: print("process 2 done, total time {}".format(time.perf_counter() - start))) 
  
  print("==== no schedule")
  do_example(False) 
  print("==== with schedule")
  do_example(True) 
  input("")
 
if __name__ == "__main__":
  import os, re, sys, hashlib
  fits = []
  with open(os.path.abspath(__file__)) as this_file:
    for line in this_file:
      line_splat = line.split(" ")
      if line_splat[0] == "def":
        fun_in_file = line_splat[1].split("(")[0]
        candidate = sys.argv[1] if len(sys.argv) > 1 else "" 
        hash_head = hashlib.md5(fun_in_file.encode()).hexdigest()[:6]
        if candidate in fun_in_file or candidate in hash_head:
          fits += [(fun_in_file, hash_head)]
    if len(fits) == 1:
      to_exec = fits[0][0]
      envelope = "{}{} {}{}".format("="*8, fits[0][0], fits[0][1], "="*8)
      print(envelope)
      eval(to_exec)()
      print(envelope)
    else:
      for fit in sorted(fits, key=lambda t: t[0]):
        print("{} {}".format(*fit))
 
#  class_twentynine()
