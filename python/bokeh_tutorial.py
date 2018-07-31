def line_jupyter():
  from bokeh.io import output_file, show
  from bokeh.plotting import figure
  x = range(5, 11)
  y = range(1, 7)
  plot = figure()
  plot.line(x, y)

def line_server():
  from bokeh.layouts import widgetbox
  from bokeh.models import Slider
  from bokeh.io import curdoc

  slider_widget = Slider(start=0, end=0, step=10, title="title to the slider is as presented")
  slider_layout = widgetbox(slider_widget)
  curdoc().add_root(slider_layout)

if __name__ == '__main__':
  #line_server()
  from bokeh.layouts import widgetbox
  from bokeh.models import Slider
  from bokeh.io import curdoc

  slider_widget = Slider(start=0, end=0, step=10, title="title to the slider is as presented")
  slider_layout = widgetbox(slider_widget)
  curdoc().add_root(slider_layout)

