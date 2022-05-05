import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation
# from matplotlib.artist import Artist

plt.style.use('grayscale')

#alphabets = ['A', 'B', 'C', 'D', 'E']
 
# randomly generated array
random_array = np.random.randint(0, 2, (50, 50))
 
figure = plt.figure()
axes = figure.add_subplot(111, facecolor='red')
axes.set_axis_off()
# axes.set_position([0, 0, 1000, 1000])

def update(num):
    random_array = np.random.randint(0, 2, (50, 50))
    caxes = axes.matshow(random_array, interpolation ='nearest')
ani = matplotlib.animation.FuncAnimation(figure, update, frames=6, interval=250, repeat=True)
 
plt.show()
