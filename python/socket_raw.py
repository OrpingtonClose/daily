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

if __name__ == '__main__':
  #socket_raw()
  #gethostname()
  #ip_address_formats()
  get_port_services()
