#https://kivy.org/docs/tutorials/firstwidget.html
from kivy.app import App
from kivy.uix.widget import Widget
from kivy.graphics import Color, Ellipse, Line
from kivy.uix.button import Button
from random import random

class MyPaintWidget(Widget):
  _proc = lambda s, t, n: (t.x * (n/45) + t.x, t.y * (n/45) + t.y)
  def on_touch_down(self, touch):
    with self.canvas:
      Color(random(), random(), random())
      d = 30
      x = touch.x - d / 2
      y = touch.y - d / 2
      Ellipse(pos=(x, y), size=(d, d))
      for n in range(90):
        touch.ud['line{}'.format(n)] = Line(points=self._proc(touch, n))

  def on_touch_move(self, touch):
    for n in range(90):
      touch.ud['line{}'.format(n)].points += self._proc(touch, n)

class MyPaintApp(App):
  def build(self):
    parent = Widget()
    self.painter = MyPaintWidget()
    clearbtn = Button(text='Clear')
    clearbtn.bind(on_release=self.clear_canvas)
    parent.add_widget(self.painter)
    parent.add_widget(clearbtn)
    return parent

  def clear_canvas(self, obj):
    self.painter.canvas.clear()

if __name__ == '__main__':
  MyPaintApp().run()
