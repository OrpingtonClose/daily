from time import sleep
#https://jeffknupp.com/blog/2016/03/07/python-with-context-managers/
#https://www.programcreek.com/python/example/82530/time.perf_counter
#https://github.com/dask/dask-tutorial/blob/master/01_dask.delayed.ipynb

def show_graph(delayed):
  from uuid import uuid4
  import os.path
  from PIL import Image
  filename = os.path.join('/', 'tmp', str(uuid4()).replace('-', '') + '.png')
  delayed.visualize(filename)
  Image.open(filename).show()
  import os
  os.remove(filename)

class Measure():
  def __init__(self, label):
    self.label = label
    self.start = None

  def __enter__(self):
    from time import perf_counter
    self.start = perf_counter()
    
#https://docs.python.org/3.6/library/string.html#format-specification-mini-language
  def __exit__(self, *args):
    from time import perf_counter
    elapsed_time = perf_counter() - self.start
    print("{}: {:0.2} sec".format(self.label, elapsed_time)) 

def inc(x):
  sleep(1)
  return x + 1

def add(x, y):
  sleep(1)
  return x + y

def dask_delayed():
  with Measure("simple functions"):
    x = inc(1)
    y = inc(2)
    z = add(x, y)

  with Measure("dask - delayed"):
    from dask import delayed
    x = delayed(inc)(1)
    y = delayed(inc)(2)
    z = delayed(add)(x, y)
    z.compute()
  
  show_graph(z)

def dask_needlessly_complicated_delayed():
  from dask import delayed
  from random import randint, choice
  calcs = [delayed(inc)(1), delayed(inc)(2)]
  calcs.append(delayed(add)(*calcs[0:1]))
  #doesn't worj with 15 increments here. why?
  for num in range(5):
    d = delayed(inc)(num)
    print(d)
    calcs.append(delayed(inc)(num))
  
  for _ in range(15):
    left = choice(calcs)
    right = choice(calcs)
    while left is right:
      right = choice(calcs)

    calculation = delayed(add)(left, right)
    print(calculation)
    calcs.append(calculation)

  calculation.calculate()
  show_graph(calculation)

def dask_delayed_loop():
  from dask import delayed
  data = [1, 2, 3, 4, 5, 6, 7, 8]
  with Measure("sequential loop"):
    results = []
    for x in data:
      y = inc(x)
      results.append(y)
    print("the summation of {} is {}".format(data, sum(results)))

  with Measure("parallel loop"):
    results = []
    for x in data:
      y = delayed(inc)(x)
      results.append(y)
    import dask
    print("the summation of {} is {}".format(data, sum(dask.compute(results)[0])))
    
def dask_arrays_distributed():
  #https://hub.mybinder.org/user/dask-dask-examples-xa8fu4x8/notebooks/array.ipynb
  from dask.distributed import Client, progress
  client = Client(processes=False, threads_per_worker=4, n_workers=1, memory_limit='2GB')
  import dask.array as da
  x = da.random.random((10000, 10000), chunks=(1000, 1000))
  y = x + x.T
  z = y[::2, 5000:].mean(axis=1)
  import subprocess
  # the dashboard doesn't show anything
  subprocess.Popen(["firefox","http://localhost:8787"])
  print(z.compute())

if __name__ == '__main__':
#  dask_delayed()
#  dask_needlessly_complicated_delayed()
#  dask_delayed_loop()
  dask_arrays_distributed()
