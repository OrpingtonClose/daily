import torch
import time
ROWS = 10
COLS = 100
board = torch.zeros([ROWS,COLS], dtype=torch.bool).random_()
while True:
    time.sleep(1)
    new_board = torch.zeros([ROWS,COLS], dtype=torch.bool)
    s = "="*COLS
    for row in range(ROWS):
        s += "\n"
        for col in range(COLS):
            c = 0
            try:
                c += board[row-1, col-1]
            except: pass
            try:
                c += board[row, col-1]
            except: pass
            try:
                c += board[row+1, col-1]
            except: pass
            try:
                c += board[row-1, col]
            except: pass
            try:
                c += board[row+1, col]
            except: pass
            try:
                c += board[row-1, col+1]
            except: pass
            try:
                c += board[row, col+1]
            except: pass
            try:
                c += board[row+1, col+1]
            except: pass
            if c in [2, 3] and board[row, col] == True:
                new_board[row, col] = True
            if c == 3 and board[row, col] == False:
                new_board[row, col] == True
            s += "X" if new_board[row, col] else " "
    board = new_board
    print(s)
