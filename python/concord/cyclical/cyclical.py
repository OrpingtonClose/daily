import sys
import concord
import time
from concord.computation import (
    Computation,
    Metadata,
    StreamGrouping,
    serve_computation
)

class Cyclical(Computation):
# all process timer can only start if a timer is set, or a record is passed upstream. 
# this deployment cant be killed using the `concord kill -a` command due to timer needing to fire to process the kill
    def init(self, ctx):
        self.started = False
        self.concord_logger.info("init")
        ctx.set_timer("start_cycle", int(round(time.time() * 1000)))

    def destroy(self):
        pass

    def process_timer(self, ctx, key, timer):
        self.concord_logger.info("process_timer")
        ctx.produce_record("cycle", "something", "=====start this cycle------>>>")
        if self.started == False:
            self.started = True
            ctx.set_timer("start_cycle", int(round(time.time() * 1000)))

    def process_record(self, ctx, record):
        self.concord_logger.info("{}:{}:{}".format(record.key, record.data, record.time))
        time.sleep(2)
        ctx.produce_record("cycle", "something", "444")

    def metadata(self):
        return Metadata(
            name='cyclical',
            istreams=[("cycle", StreamGrouping.GROUP_BY)],
            ostreams=["cycle"])

serve_computation(Cyclical())

