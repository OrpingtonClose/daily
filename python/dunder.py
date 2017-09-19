# https://docs.python.org/3/library/operator.html?highlight=__and#operator.__and__
class Dunder:
  def __or__(self, other):
    print("__or__ {}".format(other))
    return self

  def __and__(self, other):
    print("__and__ {}".format(other))
    return self
 
Dunder() & "something" | "ffff"

