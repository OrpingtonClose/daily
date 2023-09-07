import click
import requests

@click.command("hello")
@click.version_option("0.1.0", prog_name="hello")
def hello():
  click.echo("Hello, World!")

@click.command("syn")
def syn():
  click.echo(str(int(r.json()['data']['head_slot'])  +int( r.json()['data']['sync_distance'])))


if __name__ == "__main__":
  r = requests.get('http://127.0.0.1:3500/eth/v1/node/syncing')
  d = r.json()['data']
  head = int(d['head_slot'])
  distance = int(d['sync_distance'])
  al_blocks = head + distance
  ratio = head / distance
  click.echo("head block: {:_>30}".format(head))
  click.echo("distance till end: {:_>30}".format(distance))
  click.echo("total blocks: {:_>30}".format(al_blocks))
  click.echo("ratio: {:_>30.2f}".format(ratio))
