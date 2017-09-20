def function_one():
  print("def function_one():")
def function_two():
  print("def function_two():")
def function_three():
  print("def function_three():")
def function_four():
  print("def function_four():")
def function_five():
  print("def function_five():")
def function_six():
  print("def function_six():")

if __name__ == "__main__":
  import argparse, os, re
  parser = argparse.ArgumentParser(description="choose a function to call")
  functions_found = []
  with open(os.path.abspath(__file__)) as this_file:
    for line in this_file:
      line_split = line.split(" ")
      if line_split[0] == "def":
        functions_found += [line_split[1].split("(")[0]]
  for (num, fun) in enumerate(functions_found):
    parser.add_argument("-{}".format(str(num)), "--{}".format(fun), action="store_true")
  for fun, was_passed in parser.parse_args()._get_kwargs():
    if was_passed:
      eval("{}()".format(fun))

