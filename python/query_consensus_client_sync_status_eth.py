import click
import requests

@click.command("hello")
@click.version_option("0.1.0", prog_name="hello")
def hello():
  click.echo("Hello, World!")

@click.command("syn")
def syn():
  click.echo(str(int(r.json()['data']['head_slot'])  +int( r.json()['data']['sync_distance'])))


def go():
  r = requests.get('http://127.0.0.1:3500/eth/v1/node/syncing')
  d = r.json()['data']
  head = int(d['head_slot'])
  distance = int(d['sync_distance'])
  al_blocks = head + distance
  ratio = 1 if distance == 0 else head / distance
  print("head block: {:_>30}".format(head))
  print("distance till end: {:_>30}".format(distance))
  print("total blocks: {:_>30}".format(al_blocks))
  print("ratio: {:_>30.2f}".format(ratio))

if __name__ == "__main__":
  go()
