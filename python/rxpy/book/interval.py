from rx import Observable
import time


def see_difference(fun):
  start = time.time()
  obs = fun(Observable.interval(1000).map(lambda a: (a, time.time() - start))) #.publish()
  obs.take(4).subscribe(lambda x: print("First subscriber {}".format(x)))
  obs.connect()
  time.sleep(2)
  obs.take(4).subscribe(lambda x: print("Second subscriber {}".format(x)))
  time.sleep(10)

print("publish")

#see_difference(lambda o: o.publish())

print("replay(None)")

see_difference(lambda o: o.replay(None))

time.sleep(10)
