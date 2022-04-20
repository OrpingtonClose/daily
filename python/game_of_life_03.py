import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as anim

width = 100
height = 100

fig = plt.figure()
fig.set_size_inches(width /10, height/10)
ax = fig.add_axes([0, 0, 1, 1], frameon=False, aspect=1)
ax.set_xticks([])
ax.set_yticks([])

images = []

board = np.random.default_rng().integers(0, 1, size=(height, width), endpoint=True) == 1
#board = np.zeros((height, width))
#board[width // 2] = 1

zero_vertical = np.zeros((height, 1))
zero_horizontal = np.zeros((1, width))
nc0 = lambda x, y: np.concatenate((x, y), axis=0)
nc1 = lambda x, y: np.concatenate((x, y), axis=1)

move_row_minus_1 = lambda b: nc0(zero_horizontal, b[:-1,:])
move_row_plus_1 = lambda b: nc0(b[1:,:], zero_horizontal)

move_col_minus_1 = lambda b: nc1(zero_vertical, b[:,:-1])
move_col_plus_1 = lambda b: nc1(b[:,1:], zero_vertical)

images.append([plt.imshow(board, cmap='Greys', vmin=0, vmax=1, animated=True)])

iterations = 250
for i in range(iterations):
    coords = []

    coords += [move_col_minus_1(move_row_minus_1(board))] # -1, -1
    coords += [move_col_minus_1(board)] # 0, -1
    coords += [move_row_plus_1(move_col_minus_1(board))] # +1, -1
    coords += [move_row_minus_1(board)] # -1, 0
    coords += [move_row_plus_1(board)] # +1, 0
    coords += [move_row_minus_1(move_col_plus_1(board))] # -1, +1
    coords += [move_col_plus_1(board)] # 0, +1
    coords += [move_col_plus_1(move_row_plus_1(board))] # +1, +1

    neighbour_sums = board.copy() + sum(coords)
    new_board = board.copy()
    board_make_not_alive = np.isin(neighbour_sums, [0, 1, 4, 5, 6, 7, 8]) & (board == 1)
    board_make_alive = np.isin(neighbour_sums, [3]) & (board == 0)

    new_board[board_make_not_alive] = 0
    new_board[board_make_alive] = 1

    images.append([plt.imshow(new_board.astype("int64"), cmap='Greys', vmin=0, vmax=1, animated=True)])
    board = new_board
    print(iterations, " out of ", i)

animation = anim.ArtistAnimation(fig, images)
animation.save("random.gif", writer='imagemagick', fps=25)
