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
