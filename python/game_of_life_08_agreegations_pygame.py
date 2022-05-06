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
                new_board[row, col] = 1                  
        else:
            if num_alive in neighbors_dead_to_alive:
                new_board[row, col] = 1  
    return new_board

def draw(board, surface, cellsize, cellaggregation):
    for row, col in np.ndindex(board.shape[0]//(1+cellaggregation), board.shape[1]//(1+cellaggregation)):
        row_proper = row * (1+cellaggregation)
        col_proper = col * (1+cellaggregation)
        neighborhood = board[row_proper-cellaggregation:row_proper+cellaggregation+1, col_proper-cellaggregation:col_proper+cellaggregation+1]
        num_alive = np.sum(neighborhood)
        color = (num_alive*255)//((1+(cellaggregation*2))**2)
        pygame.draw.rect(surface, (color, color, color), (col*cellsize, row*cellsize, cellsize-1, cellsize-1))


def main(dimx, dimy, cellsize):
    pygame.init()
    surface = pygame.display.set_mode((dimx * cellsize, dimy * cellsize))
    cell_aggregation = 3
    # cells = np.zeros((dimy*(1+cell_aggregation), dimx*(1+cell_aggregation)))
    cells = np.random.randint(0, 2, (dimy*(1+cell_aggregation), dimx*(1+cell_aggregation)))
    cells[(cells.shape[0] // 2):((cells.shape[0] // 2)+1)] = 1

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
    main(100, 100, 8)
