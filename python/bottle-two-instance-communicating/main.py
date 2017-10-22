#http://docs.python-guide.org/en/latest/writing/logging/
#https://docs.python.org/2/library/subprocess.html
from bottle import run, request, get, HTTPResponse
def set_logging():
  import logging
  logger = logging.getLogger()
  handler = logging.StreamHandler()
  formatter = logging.Formatter("[%(asctime)s] %(message)s")
  handler.setFormatter(formatter)
  logger.addHandler(handler)
  logger.setLevel(logging.INFO)
  return logger

logger = set_logging()

@get('/')
def gogogo():
  return "herp"

def run_instances():
  import subprocess
  print(__file__)
  for port in [8081, 8082, 8083]:
    subprocess.Popen(["python", __file__, str(port)]) 

def run_instance(port):
  logging.info("opening port {}".format(str(port)))
  run(host='localhost', port=port, debug=True)

if __name__ == "__main__":
  import sys
  if len(sys.argv) > 1:
    if sys.argv[1] == "start":
      run_instances()
    else:
      run_instance(sys.argv[1])
  else:
    logging.info("passed: {}".format(sys.argv))

