def dummy_fun():
  print("dummy_fun")

def du2mmy_fun():
  print("dummy_fun")

def another_fun():
  print("another fun was launched successfully")

def another_fun2():
  print("some other fun was launched successfully")

def another_fun2ttrr():
  print("once more: some other fun was launched successfully")

if __name__ == '__main__':
  import argparse
  parser = argparse.ArgumentParser(description="choose a function to run") 
  
  funs_found = []
  with open(__file__) as this:
    for line in this:
      if line.startswith("def"):
        fun_name = line.split("(")[0].split(" ")[1]
        funs_found += [fun_name]

  aliases = {fun_name:[fun_name] for fun_name in funs_found}
  longest_name_char = max(len(fun_name) for fun_name in funs_found)
  for char in range(0, longest_name_char):
    for fun_name in funs_found:
      if len(fun_name) > char:
        abbr_of_interest = fun_name[0:char]
        same_abbrs = sum( 1 if fun_found.ljust(char)[0:char] == abbr_of_interest else 0 
                          for fun_found in funs_found)
        if same_abbrs == 1:
          aliases[fun_name] += [abbr_of_interest]
    
  for fun_name in funs_found:
    all_aliases = ["-" + fun_alias for fun_alias in aliases[fun_name]]
    parser.add_argument(*all_aliases, action='store_true')

  passed = parser.parse_args()
  print(passed)
