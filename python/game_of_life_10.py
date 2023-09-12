import time, random
ROWS = 5
COLS = 50

#board = [[1]*COLS]*ROWS
board = [[random.randint(0, 1) for _ in range(COLS)] for _ in range(ROWS)]
while True:
    print("=" * COLS)
    for irows, rows in enumerate(board):
        s = ""
        for icols, cols in enumerate(rows):    
            s += "X" if board[irows][icols] == 1 else " "
        print(s)
    time.sleep(0.2)
    new_board = [[0 for _ in range(COLS)] for _ in range(ROWS)]
    for irows, rows in enumerate(board):
        for icols, cols in enumerate(rows):
            mm = lambda: board[irows-1][icols-1]
            mo = lambda: board[irows-1][icols]
            mp = lambda: board[irows-1][icols+1]
            om = lambda: board[irows][icols-1]
            op = lambda: board[irows][icols+1]
            pm = lambda: board[irows+1][icols-1]
            po = lambda: board[irows+1][icols]
            pp = lambda: board[irows+1][icols+1]
            r = 0
            if icols == 0 and irows == 0:
                r += op()
                r += po()
                r += pp()
            elif icols == (COLS - 1) and irows == 0:
                r +=  om()
                r +=  po()
                r +=  pm()
            elif icols == 0 and irows == (ROWS - 1):
                r =  op()
                r +=  mo()
                r +=  mp()
            elif icols == (COLS - 1) and irows == (ROWS - 1):
                r =  om()
                r +=  mo()
                r +=  mm()
            elif icols == 0:
                r = mo()
                r +=  po()
                r +=  mp()
                r +=  op()
                r +=  pp()
            elif icols == (COLS - 1):
                r += mo()
                r +=  po()
                r +=  mm()
                r +=  om()
                r +=  pm()
            elif irows == 0:
                r += om()
                r += op()
                r += pm()
                r += po()
                r += pp()
            elif irows == (ROWS - 1):
                r += om()
                r +=  op()
                r +=  mm()
                r +=  mo()
                r +=  mp()
            else:
                r += mm()
                r +=  om()
                r +=  pm()
                r +=  mo()
                r +=  po()
                r +=  mp()
                r +=  op()
                r +=  pp()
            c = board[irows][icols] 
            if c == 1 and r in [2, 3]:
                new_board[irows][icols] = 1
            if c == 0 and r in [3]:
                new_board[irows][icols] = 1
    board = new_board

