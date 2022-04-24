import numpy as np
from scipy import signal
from time import sleep
from collections import deque

class AsciiArt:
    def hello(self):
        print(r"""
 .----------------.  .----------------.  .-----------------. .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. |
| |  ________    | || |     ____     | || | ____  _____  | || |  _________   | |
| | |_   ___ `.  | || |   .'    `.   | || ||_   \|_   _| | || | |_   ___  |  | |
| |   | |   `. \ | || |  /  .--.  \  | || |  |   \ | |   | || |   | |_  \_|  | |
| |   | |    | | | || |  | |    | |  | || |  | |\ \| |   | || |   |  _|  _   | |
| |  _| |___.' / | || |  \  `--'  /  | || | _| |_\   |_  | || |  _| |___/ |  | |
| | |________.'  | || |   `.____.'   | || ||_____|\____| | || | |_________|  | |
| |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------' 
            """)

class GameOfLifeBoard(np.ndarray, AsciiArt):
    def __init__(self, *args, **kwargs):
        self.fill(0)
        self[:,self.shape[1]//2] = 1
        self.kernel = np.ones((3, 3))
        self.stay_alive = np.array([2, 3])
        self.make_alive = np.array([3])        

    def progress(self):
        sums = signal.convolve(self, self.kernel, mode="same")
        stay_alive = np.isin(sums, self.stay_alive)
        is_alive_now = self == 1
        stay_alive_result = is_alive_now & stay_alive

        make_alive = np.isin(sums, self.make_alive)
        is_dead_now = self == 0
        make_alive_result = is_dead_now & make_alive

        alive_result = make_alive_result | stay_alive_result

        self.fill(0)
        self[alive_result] = 1

    def print(self):
        bc = self.copy().astype("str")
        bc[self.astype("bool")] = "x"
        bc[~self.astype("bool")] = " "
        print(np.append(bc, np.array([['\n']]*self.shape[0]), axis=1).astype(object).sum())

    @property
    def alive(self):
        return int(self.sum())
#works only with 50 columns somehow
c = GameOfLifeBoard((22, 51))
q = deque()
q.append(c.alive)
while True:
    c.progress()
    c.print()
    sleep(0.5)
    q.append(c.alive)
    if len(q) == 10:
      _ = q.popleft()
      if len([n for n in q for m in q if n != m]) == 0:
          break

c.hello()


