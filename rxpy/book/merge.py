from rx import Observable
from time import sleep

def generate_events(delay):
  for i in range(5):
    sleep(delay)
    yield "delay {}".format(delay) 

def generate_observables(list_of_delays):
  def get_iterable():
    for delay in list_of_delays:
      yield Observable.from_iterable(generate_events(delay))
  return Observable.from_iterable(list(get_iterable()))

print("Merge_all)
generate_observables([1,2]).merge_all().subscribe(print)

print("concat_all)
generate_observables([1,2]).concat_all().subscribe(print)

#Observable.from_iterable(generate_observables([1,2]))\
#          .merge_all()\
#          .subscribe(print)
