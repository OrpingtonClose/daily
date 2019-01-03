def iterate(iterator):
  print("Next")
  print(next(iterator))
  print(next(iterator))
  print("for loop")
  for i in iterator:
    print(i)

class next_impl:
  def __init__(self):
    self.i = 0

  def __iter__(self):
    return self

  def __next__(self):
    if self.i > 5:
      raise StopIteration 
    self.i += 1
    return self.i

collection = list([1,2,3,4,5])
iterator = iter(collection)

print("iterate(iterator)")
iterate(iterator)
print("iterate(next_impl())")
iterate(next_impl())
