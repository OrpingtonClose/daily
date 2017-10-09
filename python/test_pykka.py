from pykka import ThreadingActor
from pykka import ActorRegistry

class Adder(ThreadingActor):
  def add_one(self, i):
    return i + 1

class Greeter(ThreadingActor):
  def on_receive(self, message):
    print(repr(message))
    print("Hi there!")

if __name__ == '__main__':
  actor_ref = Greeter.start()
  actor_ref.tell({'msg': 'herp'})
#  data = [1,2,3,4]
#  adder = Adder.start().proxy()
#  for datum in data:
#    print(adder.add_one(datum))
  _ = input("press anything to stop")
  ActorRegistry.stop_all()
