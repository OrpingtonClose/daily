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
        pass

    def process_record(self, ctx, record):
        self.concord_logger.info("process record")
        self.concord_logger.info("=====================")
        for key, val in record.__dict__.items():
            self.concord_logger.info("{}:{}".format(key, val))

    def metadata(self):
        return Metadata(
            name='final',
            istreams=[("outstream", StreamGrouping.GROUP_BY)],
            ostreams=[])

serve_computation(Final())
