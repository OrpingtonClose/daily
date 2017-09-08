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

if __name__ == "__main__":
  class_seven()
