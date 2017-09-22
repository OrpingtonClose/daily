import concord, time
from concord.computation import Computation, Metadata, serve_computation

class MultiInstance(Computation):
  def __init__(self, name):
    self.name = name

  def init(self, ctx):
    ctx.set_timer("{} timer".format(self.name), int(round(time.time() * 1000)))

  def process_timer(self, ctx, key, timer):
    ctx.produce_record("nothing_going_here", "what", self.name)
    ctx.set_timer("{} timer".format(self.name), int(round(time.time() * 1000)) + 1000)
    #self.concord_logger.info("timer tick: {}".format(self.name))

  def process_record(self, ctx, record):
    pass

  def metadata(self):
    return Metadata(name=self.name, istreams=[], ostreams=["nothing_going_here"])

class Gatherer(Computation):
  def process_record(self, ctx, record):
    self.concord_logger.info("{}:{}".format(record.key, record.data))

  def metadata(self):
    return Metadata(name="gatherer", istreams=["nothing_going_here"], ostreams=[])

  def init(self, ctx):
    pass

  def process_timer(self, ctx, key, timer):
    pass


if __name__ == "__main__":	
  import sys
  if len(sys.argv) > 1:
    serve_computation(MultiInstance(sys.argv[1]))
  else:
    serve_computation(Gatherer())
