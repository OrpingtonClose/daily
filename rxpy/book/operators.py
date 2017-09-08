from rx import Observable
from iterator import next_impl 

print("======={}".format(__name__))

def map_obs():
  Observable.from_iterable(next_impl())\
            .map(lambda x: x**2)\
            .subscribe(print)

def group_obs():
  def obs():
    return Observable.from_iterable(next_impl()).group_by(lambda x: x % 2)

  print("obs.subscribe(print)")
  obs().subscribe(print)

  print("obs.subscribe(lambda x: print(\"group key {}\".format(x.key)))")
  obs().subscribe(lambda x: print("group key {}".format(x.key)))

  print("obs.take(1).subscribe(lambda x: x.subscribe(print))")          
  obs().take(1).subscribe(lambda x: x.subscribe(print))          

group_obs()
