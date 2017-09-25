# https://www.safaribooksonline.com/library/view/python-high-performance/9781787282896/90ae09fb-50a7-47a4-b31c-996c486ecdb5.xhtml
import psutil
import numpy as np
from rx import Observable
from matplotlib import pyplot as plt

def create_graphical_env():
  
  POINTS_ON_X_PLOT = 200
  lines, = plt.plot([],[])
  plt.xlim(0, POINTS_ON_X_PLOT)
  plt.ylim(0, 100)
  lines.set_xdata(np.arange(POINTS_ON_X_PLOT))
  y_data = np.zeros(POINTS_ON_X_PLOT)
  
  lines.set_ydata(y_data)
  
  def update_plot(cpu_reading):
    nonlocal y_data
    np.delete(y_data, 0)
    np.insert(y_data, -1, cpu_reading)
    new_data = np.concatenate([y_data[1:], np.array([cpu_reading])])
    lines.set_ydata(new_data)
    y_data = new_data
    plt.draw()

  return update_plot
  
cpu_data = Observable.interval(10)\
                     .map(lambda x: psutil.cpu_percent())\
                     .subscribe(create_graphical_env())

plt.show()
