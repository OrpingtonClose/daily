import random
from time import sleep

if __name__ == "__main__":
    DEAD = 0
    ALIVE = 1
    board = []
    sleep_duration_in_seconds = 0.1
    ROUNDS = 1000
    DEAD_TO_ALIVE = [3]
    ALIVE_TO_DEAD = [0, 1, 4, 5, 6, 7, 8]
    ROWS = 50
    COLS = 150
    for row in range(ROWS):
        new_row = []
        for col in range(COLS):
            new_row.append(random.choice([DEAD, ALIVE]))
        board.append(new_row)
    
    for _ in range(ROUNDS):
        board_string = ""
        new_board = []
        for row in range(len(board)):
            board_string += "\n"
            new_row = []
            for col in range(len(board[row])):
                if board[row][col] == DEAD:
                    board_string += " "
                else:
                    board_string += "X"
                alive_neighbours = 0 
                if not ((row == 0) or (col == 0)):
                    alive_neighbours += board[row - 1][col - 1]

                if not (row == 0):
                    alive_neighbours += board[row - 1][col]
                
                if not ((row == 0) or (col == (COLS - 1))):
                    alive_neighbours += board[row - 1][col + 1]
                
                if not (col == (COLS - 1)):
                    alive_neighbours += board[row][col + 1]
                
                if not ((row == (ROWS - 1)) or (col == (COLS - 1))):
                    alive_neighbours += board[row + 1][col + 1]
                
                if not (row == (ROWS - 1)): 
                    alive_neighbours += board[row + 1][col]
                
                if not ((row == (ROWS - 1)) or (col == 0)):
                    alive_neighbours += board[row + 1][col - 1]
                
                if not (col == 0): 
                    alive_neighbours += board[row][col - 1]
                
                if alive_neighbours in DEAD_TO_ALIVE:
                    new_row.append(ALIVE)
                elif alive_neighbours in ALIVE_TO_DEAD:
                    new_row.append(DEAD)
                else:
                    new_row.append(board[row][col])
            new_board.append(new_row)
        print(board_string)
        board = list(new_board)
        sleep(sleep_duration_in_seconds)
