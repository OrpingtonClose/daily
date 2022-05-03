import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
import seaborn.apionly as sns
import matplotlib.animation

G = nx.grid_2d_graph(50, 50)

rows = [row for row, col in G.nodes]
cols = [col for row, col in G.nodes]
min_row = min(rows)
max_row = max(rows)
min_col = min(cols)
max_col = max(cols)

def normalize(min_row, max_row, min_col, max_col):
    def normalize_upon(row, col):
        row_normalized = ((row * 2)/(max_row - min_row)) - 1
        col_normalized = ((col * 2)/(max_col - min_col)) - 1
        return np.array([row_normalized, col_normalized])
    return normalize_upon

norm = normalize(min(rows), max(rows), min(cols), max(cols))

coords = {(row, col): norm(row, col) for row, col in G.nodes}

fig, ax = plt.subplots(figsize=(20, 20))

import random

def update(num):
    ax.clear()
    color_map = [random.choice(["yellow", "black"]) for node in G]
    nx.draw_networkx_nodes(G, node_color=color_map, pos=coords, ax=ax)

    ax.set_title("Frame random node colors animated", fontweight="bold")


ani = matplotlib.animation.FuncAnimation(fig, update, frames=6, interval=1000, repeat=True)
plt.show()
