import pygame
import numpy as np

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
col_grid = (30, 30, 60)
neighbors_dead_to_alive = [3]
neighbors_alive_to_dead = [0, 1, 4, 5, 6, 7, 8]

def step(board):
    new_board = np.zeros_like(board)

    for row, col in np.ndindex(board.shape):
        neighborhood = board[row-1:row+2, col-1:col+2]
        num_alive = np.sum(neighborhood) - board[row, col]

        if board[row, col] == 1:
            if num_alive in neighbors_alive_to_dead:
         #       color = WHITE
            # else:
         #       color = BLACK
                new_board[row, col] = 1                  
        else:
            if num_alive in neighbors_dead_to_alive:
         #       color = BLACK
                new_board[row, col] = 1  
            # else:
         #       color = WHITE
    return new_board
        #pygame.draw.rect(surface, color, (col*cellsize, row*cellsize, cellsize-1, cellsize-1))

def draw(board, surface, cellsize, cellaggregation):
    for row, col in np.ndindex(board.shape[0]//cellaggregation, board.shape[0]//cellaggregation):
        row_proper = row * cellaggregation
        col_proper = col * cellaggregation
        neighborhood = board[row_proper-1:row_proper+2, col_proper-1:col_proper+2]
        num_alive = np.sum(neighborhood)
        color = (num_alive*255)//(cellaggregation**2)
        pygame.draw.rect(surface, (color, color, color), (col*cellsize, row*cellsize, cellsize-1, cellsize-1))


def main(dimx, dimy, cellsize):
    pygame.init()
    surface = pygame.display.set_mode((dimx * cellsize, dimy * cellsize))
    cell_aggregation = 3
    cells = np.zeros((dimy*cell_aggregation, dimx*cell_aggregation))
    cells[(cells.shape[0] // 2):((cells.shape[0] // 2)+3)] = 1

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                return

        surface.fill(col_grid)
        cells = step(cells)
        draw(cells, surface, cellsize, cell_aggregation)
        pygame.display.update()

if __name__ == "__main__":
    main(90, 90, 15)
