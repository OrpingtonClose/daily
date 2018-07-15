def socket_raw():
  #https://www.safaribooksonline.com/library/view/foundations-of-python/9781430230038/ch01.html
  import socket
  sock = socket.socket()
  url = 'maps.google.com'
  port = 80
  message = ""
  message += 'GET maps/place/New+St,+Durbanville,+Cape+Town,+7550,+South+Africa\r\n'
  message += '&output=json&oe=utf8&sensor=false HTTP/1.1\r\n'
  message += 'Host: maps.google.com:80\r\n'
  message += 'User-Agent: search4.py\r\n'
  message += 'Connection: close\r\n'
  message += '\r\n'
  dest_spec = (url, port)
  sock.connect(dest_spec)
  sock.sendall(str.encode(message))
  rawreply = sock.recv(14096)
  from lxml import etree
  etree.parse(rawreply)
  print(rawreply)

def gethostname():
    import socket
    print('socket.gethostname()')
    print(socket.gethostname())
    print('socket.gethostbyname(''localhost'')')
    print(socket.gethostbyname('localhost'))
    def resolve_remote_host(remote_host):
      try:
        print("resolving {}".format(remote_host))
        socket.gethostbyname(remote_host)
      except socket.error as err_msg:
          print("error")
          print(err_msg)
    resolve_remote_host('www.python.org')
    resolve_remote_host('www.pppddfdfskjfljlsdkfjsython.org')

def ip_address_formats():
  import socket
  from binascii import hexlify
  ip_addr = '127.0.0.1'
  packed = socket.inet_aton(ip_addr)
  unpacked = socket.inet_ntoa(packed)
  print("ip {}".format(ip_addr))
  print("packed ---> {}".format(packed))
  print("hexlify(packed) ---> {}".format(hexlify(packed)))
  print("unpacked ---> {}".format(unpacked))

def get_port_services():
  #https://www.safaribooksonline.com/library/view/python-network-programming/9781786463999/62dbebcd-509c-4b04-9455-c25ec03398e9.xhtml
  import socket
  for port in range(0, 100):
    try:
      service = socket.getservbyport(port, 'tcp')
      print("tcp port {} is {}".format(port, service))
    except:
      pass

<<<<<<< HEAD
def socket_errors():
  #https://www.safaribooksonline.com/library/view/python-network-programming/9781786463999/57b98da2-c312-4952-a2b8-e09b845c454b.xhtml

  #### usage:
  #python3 % --host=www.python.org --port=80 --file=%

  import sys, socket, argparse
  parser = argparse.ArgumentParser(description="attempting to connect to sockets with full socket module error suite")
  parser.add_argument("--host", action="store", dest="host", required=False)
  parser.add_argument("--port", action="store", dest="port", type=int, required=False)
  parser.add_argument("--file", action="store", dest="file", required=False)
  given_args = parser.parse_args()
  host = given_args.host
  port = given_args.port
  filename = given_args.file
  if not host or not port or not filename:
    from subprocess import call
    result = call(["python3", __file__, 
                   "--host", "docs.microsoft.com", #"www.python.org", 
                   "--port", "443", 
                   "--file", "/en-us/windows-hardware/drivers/network/af-inet"])
    sys.exit(result)
    
  try:
    import ssl
    insecure_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s = ssl.wrap_socket(insecure_socket, ssl_version=ssl.PROTOCOL_TLSv1)
  except socket.error as e:
    print("#######Error creating socket: {}".format(repr(e)))
    sys.exit(1)
  except Exception as e:
    print("#######regular error {}".format(str(e)))
    sys.exit(1)

  try:
    s.connect((host, port))
  except socket.gaierror as e:
    print("#######Address wrong {}".format(str(e)))
    sys.exit(1)
  except socket.error as e:
    print("#######connection error {}".format(str(e)))
  except Exception as e:
    print("#######regular error {}".format(str(e)))
    sys.exit(1)

  try:
    msg = "GET {} HTTP/1.1\r\nHost: {}\r\n\r\n".format(filename, host)
    print("><=><=><=><=><=><=><=><=><=><=><=><=><=><=><")
    print(msg)
    s.sendall(msg.encode('utf-8'))
  except socket.error as e:
    print("#######error sending data {}".format(str(e)))
  except Exception as e:
    print("#######regular error {}".format(str(e)))
    sys.exit(1)

  while 1:
    try:
      #https://www.safaribooksonline.com/library/view/linux-socket-programming/0672319357/apa.html
      general_socket_options = socket.SOL_SOCKET
      receive_buffer_size = socket.SO_RCVBUF
      bufsize = s.getsockopt(general_socket_options, receive_buffer_size)
      print("#######buffer size is {}".format(bufsize))
      s.setsockopt(general_socket_options, receive_buffer_size, 400000)
      bufsize = s.getsockopt(general_socket_options, receive_buffer_size)
      print("#######buffer size is {}".format(bufsize))
      buf = s.recv(bufsize)
    except socket.error as e:
      print("#######error receiving data {}".format(str(e)))
      sys.exit(1)
    except Exception as e:
      print("#######regular error {}".format(str(e)))
      sys.exit(1)
    if len(buf) != 0:
      print("><=><=><=><=><=><=><=><=><=><=><=><=><=><=><")
      sys.stdout.write(str(len(buf.decode('utf-8'))))
      break

=======
>>>>>>> parent of 73e1d37... socket error messages; https with sockets
if __name__ == '__main__':
  #socket_raw()
  #gethostname()
  #ip_address_formats()
  get_port_services()
