#They are used for “out of band” operations on filehandles and I/O device handles.
def do_concurrent_work(fcntl_flock):
  for i in range(20):
    file = open(f, "r+")
    if fcntl_flock:
      fcntl.flock(file.fileno(), fcntl.LOCK_EX)
    counter = int(file.readline()) + 1
    file.seek(0)
    file.write(str(counter))
    file.close()
    import sys
    sys.stdout.write(" {}{}".format(counter))
    sys.stdout.flush()
    #print("{}{}{}".format(os.getpid(), "=>", counter).strip())
    time.sleep(0.1)
  
if __name__ == '__main__':
  import fcntl, os, time, multiprocessing, sys, os
  f = "counter.txt"
  for b in [True, False]:
    file = open(f, "w")
    file.write("0")
    file.close()
    print("{} fcntl.flock(, dcntl.LOCK_EX)".format("with" if b else "without"))
    with multiprocessing.Pool() as worker:
      result = worker.map_async(do_concurrent_work, [b]*5)
      result.wait()
    os.remove(f)
    print()
