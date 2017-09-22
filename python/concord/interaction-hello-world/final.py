import sys
import concord
import time
from concord.computation import (
    Computation,
    Metadata,
    StreamGrouping,
    serve_computation
)

class Final(Computation):

    def init(self, ctx):
        self.concord_logger.info("initialized")

    def destroy(self):
        self.concord_logger.info("Source destroyed")

    def process_timer(self, ctx, key, timer):
        self.concord_logger.info("process timer")

    def process_record(self, ctx, record):
        self.concord_logger.info("process record")
        #self.concord_logger.info("{}{}".format(record.key, repr(dir(record))))

    def metadata(self):
        return Metadata(
            name='final',
            istreams=["outstream", StreamGrouping.GROUP_BY],
            ostreams=[])

serve_computation(Final())

