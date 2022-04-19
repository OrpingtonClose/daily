import time

def get_board(rows, cols):
  board = []
  for row in range(rows):
    new_row = []
    for col in range(cols):
      new_row.append(0)      
    board.append(new_row)
  return board

def randomize_board(board):
  import random
  return [[random.choice([0, 1]) for _ in range(len(row))] for row in board]

def print_board(board):
  board_string = ""
  for row in board:
    board_string += "\n"
    for col in row:
      board_string += "X" if col == 1 else " " 
  print(board_string)
  return board

def transition_board(board, alive_to_dead, dead_to_alive):
  last_row = len(board)
  last_col = len(board[0])
  default_coords = []
  default_coords.append((-1, -1))
  default_coords.append((0, -1))
  default_coords.append((1, -1))
  default_coords.append((-1, 0))
  default_coords.append((1, 0))
  default_coords.append((1, 1))
  default_coords.append((0, 1))
  default_coords.append((1, 1))
  new_board = []
  for row in range(last_row):
    new_row = []
    for col in range(last_col):
      cell = board[row][col]
      coords = list(default_coords)
      if row == 0:
        coords = [c for c in coords if c[0] != -1]
      if col == 0:
        coords = [c for c in coords if c[1] != -1]
      if row == (last_row -1):
        coords = [c for c in coords if c[0] != 1]
      if col == (last_col - 1):
        coords = [c for c in coords if c[1] != 1]
      neighbours_alive = sum([board[row + r][col + c] for r, c in coords]) 
      if cell == 1:
        new_row.append(0 if neighbours_alive in alive_to_dead else 1)
      elif cell == 0:
        new_row.append(1 if neighbours_alive in dead_to_alive else 0)
      else:
        new_row.append(cell)
    new_board.append(new_row)
  return new_board

if __name__ == "__main__":
  b = print_board(randomize_board(get_board(25, 50)))
  for _ in range(50):
    time.sleep(0.2)
    b = print_board(transition_board(b, [0, 1, 4, 5, 6, 7, 8], [3]))


