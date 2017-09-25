# https://docs.scipy.org/doc/numpy/user/quickstart.html
# how to make this animated
import numpy as np
import matplotlib.pyplot as plt
from time import sleep

def mandelbrot( h,w, maxit=20 ):
    print(maxit)
    y,x = np.ogrid[ -1.4:1.4:h*1j, -2:0.8:w*1j ]
    c = x+y*1j
    z = c
    divtime = maxit + np.zeros(z.shape, dtype=int)
    for i in range(maxit):
        z = z**2 + c
        diverge = z*np.conj(z) > 2**2
        div_now = diverge & (divtime==maxit)
        divtime[div_now] = i
        z[diverge] = 2
    return divtime

im = plt.imshow(np.zeros((400, 400)))
def redraw(i):
  print(im.__dict__.items())
  im.set_data(i)
  plt.draw()

from rx import Observable
Observable.interval(2000)\
          .map(lambda x: mandelbrot(400, 400, x + 1))\
          .subscribe(redraw)

plt.show()
input("aaa")
