import sys
import concord
import time
from concord.computation import (
    Computation,
    Metadata,
    StreamGrouping,
    serve_computation
)

class First(Computation):

    def init(self, ctx):
        self.concord_logger.info("Counter initialized")
        ctx.set_timer("init", int(round(time.time() * 1000)))

    def destroy(self):
        self.concord_logger.info("Source destroyed")

    def process_timer(self, ctx, key, timer):
        self.concord_logger.info("process timer")
        ctx.produce_record("a single value", "hello world", "!")
        ctx.set_timer("process timer", int(round(time.time() * 1000)))

    def process_record(self, ctx, record):
      self.concord_logger("process record")

    def metadata(self):
        return Metadata(
            name='first',
            istreams=[],
            ostreams=["outputstream"])

serve_computation(First())
