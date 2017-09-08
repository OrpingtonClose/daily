#http://reactivex.io
from rx import Observable
obs = Observable.from_iterable(range(4))
obs.subscribe(print)


