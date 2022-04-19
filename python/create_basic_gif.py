import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as anim

width = 1000
length = 1000

fig = plt.figure()
fig.set_size_inches(width / 100, length / 100)
ax = fig.add_axes([0, 0, 1, 1], frameon=False, aspect=1)
ax.set_xticks([])
ax.set_yticks([])

m = 1000
n = 1000

images = []
for _ in range(100):
    images.append([plt.imshow(np.random.default_rng().integers(0, 1, size=(n, m), endpoint=True) == 1, cmap='Greys', vmin=0, vmax=1, animated=True)])

animation = anim.ArtistAnimation(fig, images)
animation.save("random.gif", writer='imagemagick', fps=10)
