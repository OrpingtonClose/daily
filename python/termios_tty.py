#https://docs.python.org/2/library/termios.html?highlight=termios
#type into the terminal with the keys showing
import termios, sys
fd = sys.stdin.fileno()
old = termios.tcgetattr(fd)
new = termios.tcgetattr(fd)
print("==========" + repr(old))
new[3] = new[3] & ~termios.ECHO
try:
  termios.tcsetattr(fd, termios.TCSADRAIN, new)
  passwd = input("PASSWORD:")
finally:
  termios.tcsetattr(fd, termios.TCSADRAIN, old)
print()
print("the password typed is")
print(passwd)
  

