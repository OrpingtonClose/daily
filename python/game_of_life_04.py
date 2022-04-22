import numpy as np
from matplotlib import pyplot as plt
import matplotlib.animation as animation
from scipy import signal
from time import sleep

def print_board(board):
    bc = board.copy().astype("str")
    bc[board.astype("bool")] = "x"
    bc[~board.astype("bool")] = " "
    print(np.append(bc, np.array([['\n']]*board.shape[0]), axis=1).astype(object).sum())

def make_step(board):
    conv = np.ones((3, 3))
    stay_alive = np.array([2, 3])
    make_alive = np.array([3])

    sums = signal.convolve(board, conv, mode="same")
    return ((board == 1) & (np.isin(sums, stay_alive)) | (board == 0) & (np.isin(sums, make_alive)))

def make_board():
    height = 25
    width = 100
    board = np.zeros((height, width))
    board[height//2] = 1
    return board

board = make_board()
print_board(board)

for _ in range(150):
    board = make_step(board)
    print_board(board)
    sleep(0.5)
