import getpass
from subprocess import Popen, PIPE, STDOUT
command = ["sudo", "-p", "-k", "-S", "apt-get", "install", "-y", 
           "build-essential", "python3", "python3-dev", "libssl-dev", "libgmp-dev"]

password = getpass.getpass().encode()  
password_passable = password + b"\n"
install_necessary_packages = Popen(command, stdout=None, stdin=PIPE, stderr=None)
install_necessary_packages.communicate(password_passable) 


Popen(["git", "clone", "https://github.com/nucypher/nucypher-pre-python.git"], stdout=None, stdin=PIPE, stderr=None)
os.chdir("nucypher-pre-python")
Popen(["sudo", "pip3", "install", "-e", "."], stdout=None, stdin=PIPE, stderr=None)

from npre import bbs98
pre = bbs98.PRE()
secret_key_alice = pre.gen_priv(dtype=bytes)
public_key_alice = pre.priv2pub(secret_key_alice)

secret_key_bob = pre.gen_priv(dtype=bytes)
public_key_bob = pre.priv2pub(secret_key_bob)

print("Alice secret key")
print(secret_key_alice.hex()[2:])
print("Bob secret key")
print(secret_key_bob.hex()[2:])

message = "Hello world"
encrypted_message = pre.encrypt(public_key_alice, message)
reencrypt_key = pre.rekey(secret_key_alice, secret_key_bob)
reencrypted_message = pre.reencrypt(reencrypt_key, encrypted_message)

decrypted_message = pre.decrypt(secret_key_bob, reencrypted_message)
print("is the message the same despite being decrypted by a differnt key?")
print("Yes" if decrypted_message.decode("utf-8") == message else "No")

