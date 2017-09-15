# inspiration:
# https://github.com/Maratyszcza/PeachPy/blob/master/peachpy/x86_64/__main__.py
# docs:
# https://docs.python.org/3/library/argparse.html
import argparse

parser = argparse.ArgumentParser(description="this is a command line tool")
parser.add_argument("-H", "--herp", dest="debug_level", type=int, default=0, help="Informative help message")
parser.add_argument("-M", "--merp", dest="visual_level", type=int, default=0, help="the second parameter for the command line tool")
parser.add_argument("-m", "--person",
                    dest="what person is using the tool",
                    default="operator",
                    action="store",
                    choices=("operator", "dog", "developer"),
                    help="make your choice of who you are")

# the group exclusivity doesn't work
nice_group = parser.add_mutually_exclusive_group()
nice_group.add_argument("--nice", dest="niceness level", action="store_false", help="what will happen to nice?") 

great_group = parser.add_mutually_exclusive_group()
great_group.add_argument("--great", dest="greatness level", action="store_true", help="what will happen to great?")

if __name__ == "__main__":
  print(parser.parse_args())
