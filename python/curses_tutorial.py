import curses

#https://www.pcquest.com/curses-programming-python/
#draws rectangle on borders
stdscr = curses.initscr()
stdscr.box()
stdscr.refresh()
pad = curses.newpad(100, 100)
for y, in range(100):
  for x in range(100):
    pad.addch(y, x, ord('a') + (x*x, y*y) % 26)
    pad.refresh(0, 0, 5, 5, 20, 75)

  
