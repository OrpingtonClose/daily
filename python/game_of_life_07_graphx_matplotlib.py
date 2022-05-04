import networkx as nx
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
# import seaborn.apionly as sns
import matplotlib.animation
g = nx.Graph()

rows = 25
cols = 50

def setup_state(row, col):
    return col in [25]

for row in range(1, rows + 1):
    for col in range(1, cols + 1):
        g.add_node((row, col), row=row, col=col, alive=setup_state(row, col))
        if row != 1 and col != 1:
            g.add_edge((row, col), (row-1, col-1))
        if row != rows and col != cols:
            g.add_edge((row, col), (row+1, col+1))
        if row != 1 and col != cols:
            g.add_edge((row, col), (row-1, col+1))
        if row != rows and col != 1:
            g.add_edge((row, col), (row+1, col-1))
        if row != 1:
            g.add_edge((row, col), (row-1, col))
        if row != rows:
            g.add_edge((row, col), (row+1, col))
        if col != 1:
            g.add_edge((row, col), (row, col-1))
        if col != cols:
            g.add_edge((row, col), (row, col+1))

def step(g):
    nodes = g.nodes
    for row in range(1, rows + 1):
        for col in range(1, cols + 1):
            key = (row, col)
            nodes[key]["sum_alive"] = sum([1 for e in nx.edges(g, key) if nodes[e[1]]["alive"]])
    for row in range(1, rows + 1):
        for col in range(1, cols + 1):
            key = (row, col)
            node = nodes[key]
            if node["alive"]:
                if not node["sum_alive"] in [2, 3]:
                    node["alive"] = False
            else:
                if node["sum_alive"] in [3]:
                    node["alive"] = True

def normalize(all_rows, all_cols):
    min_row = min(all_rows)
    max_row = max(all_rows)
    min_col = min(all_cols)
    max_col = max(all_cols)
    def normalize_upon(row, col):
        row_normalized = ((row * 2)/(max_row - min_row)) - 1
        col_normalized = ((col * 2)/(max_col - min_col)) - 1
        return np.array([row_normalized, col_normalized])
    return normalize_upon

norm = normalize([row for row, _ in g.nodes], [col for _, col in g.nodes])

fig, ax = plt.subplots(figsize=(10, 10))
ax.clear()
ax.set_facecolor('#eafff5')
ax.set_title("Frame random node colors animated", fontweight="bold")

def show(g):
    def update(num):
        coords = {(row, col): norm(row, col) for row, col in g.nodes}
        color_map = ["black" if g.nodes[key]["alive"] else "white" for key in g.nodes]
        nx.draw_networkx_nodes(g, node_color=color_map, pos=coords, ax=ax, node_size=75)
        step(g)
    return matplotlib.animation.FuncAnimation(fig, update, frames=6, interval=100, repeat=True)

ani = show(g)
plt.show()
