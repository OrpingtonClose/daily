import Xlib.display
display = Xlib.display.Display()
screen = display.screen()
root_window = screen.root
for window in root_window.query_tree().children:
  wm_class = window.get_wm_class()
  if wm_class:
    print("wm_name: {} |||||| wm_class: {} {}".format(window.get_wm_name(), *wm_class))


