import click

@click.command()
@click.option('--count', default=1, help='the first command')
@click.option('--name', prompt="Your Name Sir", help="http://click.pocoo.org/5/")
def hello(count, name):
  for x in range(count):
    click.echo("Hello {}!".format(name))

if __name__ == "__main__":
  import sys
  print(sys.argv)
  hello()

