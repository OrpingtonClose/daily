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

bservable.from_(["a", "b", "c", "d", "e", "f"])
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

if __name__ == "__main__":
  class_twentyfour()



A

  class_twentyfour()



