#https://www.safaribooksonline.com/library/view/python-for-unix/9780596515829/ch08.html#pyinotify
import os, sys, pyinotify

class PClose(pyinotify.ProcessEvent):
  def process_default(self, event):
    print("##### event in process_IN_CLOSE")
    for key, val in event.__dict__.items():
      print("{} --> {}".format(key, val))
    print("#####"*5)

notifier = pyinotify.ThreadedNotifier(pyinotify.WatchManager(), PClose())
notifier.daemon = True
notifier.start()

#http://man7.org/linux/man-pages/man7/inotify.7.html
file_dir_created_in_watched_dir = pyinotify.IN_CREATE
notifier._watch_manager.add_watch('/tmp', file_dir_created_in_watched_dir)

import time, os, uuid
time.sleep(2)
with open('/tmp/inotify_test{}'.format(uuid.uuid4()), 'w') as f:
  f.write("some text")
  time.sleep(2)
  f.close()
  os.remove(f.name)
input("press anything to stop")

#while True:
#  import time
#  time.sleep(1)
#print("##### monitoring started")
#wm.add_watch('/tmp', pyinotify.IN_CREATE)
#
#input("press anything to stop")
#notifier.process_events()
#if notifier.check_events():
#  notifier.read_events()
#notifier.stop()
