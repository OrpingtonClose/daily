#unfinished

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as anim

width = 1000
height = 1000

fig = plt.figure()
fig.set_size_inches(width / 100, height / 100)
ax = fig.add_axes([0, 0, 1, 1], frameon=False, aspect=1)
ax.set_xticks([])
ax.set_yticks([])

images = []
board = np.random.default_rng().integers(0, 1, size=(length, width), endpoint=True) == 1

zero_vertical = np.zeros((height, 1))
zero_horizontal = np.zeros((1, width))
nc0 = lambda x, y: np.concatenate((x, y), axis=0)
nc1 = lambda x, y: np.concatenate((x, y), axis=1)

move_row_minus_1 = lambda b: nc0(zero_horizontal, b[:-1,:])
move_row_plus_1 = lambda b: nc0(b[1:,:], zero_horizontal)

move_col_minus_1 = lambda b: nc1(zero_vertical, b[:,:-1])
move_col_plus_1 = lambda b: nc1(b[:,1:], zero_vertical)

coords = []

coords += [move_col_minus_1(move_row_minus_1(board))] # -1, -1
coords += [move_col_minus_1(board)] # 0, -1
coords += [move_row_plus_1(move_col_minus_1(board))] # +1, -1
coords += [move_col_minus_1(board)] # -1, 0
coords += [move_row_plus_1(board)] # +1, 0
coords += [move_row_minus_1(move_col_plus_1(board))] # -1, +1
coords += [move_col_plus_1(board)] # 0, +1
coords += [move_col_plus_1(move_row_plus_1(board))] # +1, +1



#np.random.default_rng().integers(0, 1, size=(length, width), endpoint=True) == 1
#plt.imshow(np.random.default_rng().integers(0, 1, size=(length, width), endpoint=True) == 1, cmap='Greys', vmin=0, vmax=1, animated=True)

for _ in range(100):
    images.append([])

animation = anim.ArtistAnimation(fig, images)
animation.save("random.gif", writer='imagemagick', fps=10)
