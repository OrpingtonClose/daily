from rx.subjects import Subject
from rx.concurrency import QtScheduler
import sys

#source:
#https://raw.githubusercontent.com/ReactiveX/RxPY/master/examples/timeflies/timeflies_qt.py

def try_import():
  try:
    import PyQt5 
  except ImportError:
    print("Please run this command in bash:")
    print("sudo -H pip3 install pyqt5")
    return True
  return False

if try_import():
  sys.exit()

from PyQt5 import QtCore
from PyQt5.QtWidgets import QApplication, QWidget, QLabel

class Window(QWidget):
  def __init__(self):
    super(QWidget, self).__init__()
    self.setWindowTitle("Rx for Python rocks")
    self.resize(600, 600)
    self.setMouseTracking(True)
    self.mousemove = Subject()

  def mouseMoveEvent(self, event):
    event_tuple = ( event.x(), event.y() )
    self.mousemove.on_next( event_tuple )

def main():
  app = QApplication(sys.argv)
  scheduler = QtScheduler(QtCore)
  window = Window()
  window.show()

  text = 'some text on the screen'
  labels = [QLabel(char, window) for char in text]

  def handle_label(i, label):
    def on_next(pos):
      x, y = pos
      label.move(x + i * 12 + 15, y)
      label.show()

    window.mousemove.delay(i*100, scheduler=scheduler).subscribe(on_next)
  for i, label in enumerate(labels):
    handle_label(i, label)

  sys.exit(app.exec_())

if __name__ == '__main__':
  main() 
