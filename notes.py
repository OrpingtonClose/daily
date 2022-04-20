import numpy as np
diag_kernel = np.ones((3, 3), dtype=np.int8)
from scipy import signal
b = np.zeros((10, 10))
b[5] = 1
signal.convolve(b, diag_kernel, mode='same') - b

https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.convolve.html
