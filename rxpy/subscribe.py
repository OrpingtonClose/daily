from rx import Observable
from iterator import next_impl 

obs = Observable.from_iterable(next_impl())
obs2 = obs.take(2)

obs2.subscribe(on_next=lambda x: print("Next item: {}".format(x)),
              on_completed=lambda: print("no more data"))
