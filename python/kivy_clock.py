#Kivy Blueprints
#Making the clock tick
#https://www.safaribooksonline.com/library/view/kivy-blueprints/9781783987849/ch01s03.html
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout

class ClockLayout(BoxLayout):
  from kivy.properties import ObjectProperty
  time_prop = ObjectProperty(None)

class ClockApp(App):
  def update_time(self, nap):
    import datetime
    self.root.ids.time.text = datetime.datetime.now().strftime("[b]%H[/b]:%M:%S")
  def on_start(self):
    from kivy.clock import Clock
    Clock.schedule_interval(self.update_time, 1)

if __name__ == "__main__":
  kivy_file_path = "clock.kv"
  with open("clock.kv", "w") as kivy_file:
    kivy_file.write("""
ClockLayout:
  time_prop: time
  Label:
    id: time
    font_name: 'Roboto'
    markup: True
""")
#BoxLayout:
#  orientation: 'vertical'
#  Label:
#    id: time
#    font_name: 'Roboto'
#    text: '[b]00:00:00[/b]'
#    markup: True
#""")
  from kivy.core.window import Window
  from kivy.utils import get_color_from_hex
  Window.clearcolor = get_color_from_hex("#101216")
  ClockApp().run()
  import os
  os.remove(kivy_file_path)
