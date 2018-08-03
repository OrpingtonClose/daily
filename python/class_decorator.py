#Class Decorator Example
#https://www.safaribooksonline.com/videos/python-epiphanies/9781491926130/9781491926130-video216442
def class_counter(klass):
  klass.count = 0
  klass.__init_original__ = klass.__init__
  def new_init(self, *args, **kwargs):
    klass.count += 1
    klass.__init_original__(self, *args, **kwargs)
  klass.__init__ = new_init
  return klass

@class_counter
class Something():
  pass

print(Something.count)
dump = Something()
dump = Something()
dump = Something()
dump = Something()
print(Something.count)

print("=" * 10)
print("print the name of a declared class:")

def another_decorator(klass):
  print(klass.__name__)
  return klass

print("before declaration")

@another_decorator
class OtherThing():
  pass

print("after declaration")
print("before instantiation")
OtherThing()
print("after instantiation")

