def one():
  pass

def two():
  pass

import inspect, sys
for key, val in dict(globals()).items():
  if callable(val):
    print(key)

