import networkx as nx
from networkx.drawing.nx_agraph import graphviz_layout
import matplotlib
import matplotlib.pyplot as plt

#https://stackoverflow.com/a/67863156
# import os
# os.environ.pop("QT_QPA_PLATFORM_PLUGIN_PATH")

#https://networkx.org/documentation/stable/reference/classes/generated/networkx.Graph.neighbors.html

g = nx.Graph()

rows = 50
cols = 100

def setup_state(row, col):
    return col in [50]
    #return (col in [50] and row in [15, 14, 13]) or (row in [15] and col in [49]) or (row in [14] and col in [48])

for row in range(1, rows + 1):
    for col in range(1, cols + 1):
        attrs = {}
        alive = setup_state(row, col)
        if alive:
            attrs["alive"] = None
        else:
            attrs["dead"] = None
        g.add_node((row, col), row=row, col=col, **attrs)

for row in range(1, rows + 1):
    for col in range(1, cols + 1):
        if row != 1 and col != 1:
            g.add_edge((row, col), (rol-1))
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
    #[len(list(g.neighbors(n))) for n in g.nodes]

def step(g):
    new_g = nx.Graph()
    new_g.add_edges_from(g.edges)
    for key in list(g):
        node_attributes = dict(g.nodes.get(key))
        is_node_alive = node_attributes["alive"]
        alive_neighbors = 0
        for neighbour in nx.all_neighbors(g, key):
            is_neighbor_alive = dict(g.nodes.get(neighbour))["alive"]
            if is_neighbor_alive:
                alive_neighbors += 1

        new_alive_status = False
        if is_node_alive:
            if alive_neighbors in [2, 3]:
                new_alive_status = True
        else:
            if alive_neighbors in [3]:
                new_alive_status = True
        new_g.add_node(key, alive=new_alive_status)
    return new_g

def show(g):
    max_row = max([row for row, col in g.nodes])
    max_col = max([col for row, col in g.nodes])

    board_string = "=" * max_col
    for row in range(1, max_row + 1):
        board_string += "\n"
        for col in range(1, max_col + 1):
            if g.nodes.get((row, col))['alive'] == True:
                board_string += "X"
            else:
                board_string += " "
    print(board_string)

def analysis(g):
    #alot of things:
    #print("triangles %s:" % nx.triangles(g))
    print("transitivity %s:" % nx.transitivity(g))
    #alot of things:
    #print("clustering %s:"  % nx.clustering(g))
    print("average_clustering %s:" % nx.average_clustering(g))
    #alot of things:
    #print("square_clustering %s:" % nx.square_clustering(g))
    #alot of things:
    #print("generalized_degree %s:" % nx.generalized_degree(g))
    nx.get_node_attributes(g, "alive")

import time
for _ in range(100):
    analysis(g)
    show(g)
    g = step(g)
    time.sleep(1)


        #neighbor_alive_nodes = len([n for n in nx.all_neighbors(g, key) if g.nodes.get(n)["alive"]])

    #https://askubuntu.com/questions/308128/failed-to-load-platform-plugin-xcb-while-launching-qt5-app-on-linux-without/1069502#1069502
    #https://pygraphviz.github.io/documentation/stable/install.html

    # _, axes = plt.subplots()
    # positions = graphviz_layout(g)

    # matplotlib.rc("font", family="Arial")
    # matplotlib.style.use("grayscale")
    # attrs = {
    #     "edge_color" : "gray",
    #     "edgecolors" : "black", # For Networkx 2.0
    #     "linewidths" : 1,       # For Networkx 2.0
    #     "font_family" : "Liberation Sans Narrow",
    #     "font_size" : 14,
    #     "node_color" : "black",
    #     "node_size" : 70,
    #     "width" : 2,
    # }
    # # thick_attrs = attrs.copy()
    # # thick_attrs["alpha"] = 0.5
    # # thick_attrs["width"] = 15

    # # small_attrs = attrs.copy()
    # # small_attrs["node_size"] = 50
    # # small_attrs["font_size"] = 10

    # # medium_attrs = small_attrs.copy()
    # #medium_attrs["node_size"] = 250    

    # #axes.tick_params(labelbottom="off")
    # #axes.tick_params(labelleft="off")
    # #axes.set_title("herp")

    # print("1")

    # x_values, y_values = zip(*positions.values())
    # x_max = max(x_values)
    # y_max = max(y_values)
    # x_min = min(x_values)
    # y_min = min(y_values)
    # x_margin = (x_max - x_min) * 0.1
    # y_margin = (y_max - y_min) * 0.1
    # try:
    #     axes.set_xlim(x_min - x_margin, x_max + x_margin)
    #     axes.set_ylim(y_min - y_margin, y_max + y_margin)
    # except AttributeError:
    #     axes.xlim(x_min - x_margin, x_max + x_margin)
    #     axes.ylim(y_min - y_margin, y_max + y_margin)

    # print("2")
    # nx.draw_networkx(g, positions, **attrs)
    # print("3")
    # plt.tight_layout()
    # plt.show()

