def peachpy_one():
  import peachpy
  import peachpy.x86_64
  
  x = peachpy.Argument(peachpy.int32_t)
  y = peachpy.Argument(peachpy.int32_t)
  
  with peachpy.x86_64.Function("Add", (x, y), peachpy.int32_t) as asm_function:
    reg_x = peachpy.x86_64.GeneralPurposeRegister32()
    reg_y = peachpy.x86_64.GeneralPurposeRegister32()
  
    peachpy.x86_64.LOAD.ARGUMENT(reg_x, x)
    peachpy.x86_64.LOAD.ARGUMENT(reg_y, y)
    for _ in range(1000):
      peachpy.x86_64.ADD(reg_x, reg_y)
  
    peachpy.x86_64.RETURN(reg_x)
  
  py_fun = asm_function.finalize(peachpy.x86_64.abi.detect()).encode().load()
  print("done creating function") 

  import time
  start = time.perf_counter()
  for _ in range(100000):
    _ = py_fun(2,2) 
  print("end time for pypeach is {}".format(time.perf_counter() - start))

  start = time.perf_counter()
  for _ in range(100000):
    _ = 2+2
  print("end time for statement is {}".format(time.perf_counter() - start))
  
if __name__ == "__main__":
  peachpy_one() 
