#zmq installation:
#http://www.powerbrowsing.com/2016/02/installing-zeromq-pyzmq-on-ubuntu/

#from:
#https://www.safaribooksonline.com/library/view/mastering-ipython-40/9781785888410/ch04s02.html

def server():
  import zmq, time, random
  print("##### server started")
  
  context = zmq.Context()
  wait_to_reply_to_a_request = zmq.REP
  socket = context.socket(wait_to_reply_to_a_request)
  socket.bind("tcp://*:5678")
  
  while True:
    message = socket.recv()
    print("Received message {}".format(message))
    time.sleep(2)
    socket.send(str(random.random()).encode('utf-8'))

def client():
  import zmq
  print("##### client started")
  context = zmq.Context()
  socket = context.socket(zmq.REQ)
  socket.connect("tcp://localhost:5678")
  socket.send(b"please gib")
  message = socket.recv()
  print("message is {}".format(message))

if __name__ == '__main__':
  import argparse
  parser = argparse.ArgumentParser()
  group = parser.add_mutually_exclusive_group()
  group.add_argument("--server", action='store_true')
  group.add_argument("--client", action='store_true')
  passed = parser.parse_args()

  if passed.server:
    server()
  elif passed.client:
    client()
  else:
    from subprocess import call, Popen
    pid = Popen(["python3", __file__, "--server"]).pid
    for _ in range(5):
      call(["python3", __file__, "--client"])
    call(["kill", str(pid)])
