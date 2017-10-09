import sys
import concord
import time
import json
from concord.computation import (
    Computation,
    Metadata,
    StreamGrouping,
    serve_computation
)

def new_time(ctx, offset_in_millis):
    current_time = time.time()
    current_millis = current_time * 1000
    rounded_time = int(round(current_millis)) + offset_in_millis
    ctx.set_timer("init", rounded_time)

class First(Computation):

    def init(self, ctx):
        self.concord_logger.info("Counter initialized")
        new_time(ctx, 3000)

    def destroy(self):
        self.concord_logger.info("Source destroyed")

    def process_timer(self, ctx, key, timer):
        self.concord_logger.info("process timer")
        ctx.produce_record("outstream", "hello world", json.dumps({"value":{"field1":"val"}})
        new_time(ctx, 3000)

    def process_record(self, ctx, record):
      self.concord_logger("process record")

    def metadata(self):
        return Metadata(
            name='first',
            istreams=[],
            ostreams=["outstream"])

serve_computation(First())

