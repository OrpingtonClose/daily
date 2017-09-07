from rx.subjects import Subject

s = Subject()
s.subscribe(lambda a: print("Subject emitted value: {}".format(a)))
s.on_next(1)
s.on_next(2)
