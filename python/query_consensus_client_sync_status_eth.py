import fire
import requests

def consensus():
  r = requests.get('http://127.0.0.1:3500/edth/v1/node/syncing')
  d = r.json()['data']
  head = int(d['head_slot'])
  distance = int(d['sync_distance'])
  al_blocks = head + distance
  ratio = 1 if distance == 0 else head / distance
  print("head block: {:_>30}".format(head))
  print("distance till end: {:_>30}".format(distance))
  print("total blocks: {:_>30}".format(al_blocks))
  print("ratio: {:_>30.2f}".format(ratio))

def execution(t):
    import requests
    import re
    import time
    print(t)
    req = lambda: requests.get('http://127.0.0.1:8545', headers={"Content-type": "application/json"}, json={"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1})
    rs = []
    res = dict()
    for _ in range(t):
        time.sleep(5)
        print("fetching")
        rs.append(req())
    for r in rs:
        for key, value in {k: int(v, 16) for k, v in r.json()["result"].items()}.items():
            k = res.get(key, [])
            k.append(value)
            res[key] = k
    while True:
        for key, val in res.items():
            print_string = ""
            key_formatted = " ".join([m.group(0).lower() for m in re.finditer('.+?(?:(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|$)', key)])
            print_string = f"{key_formatted:.<25} "
            i = 0
        for key, val in res.items():
            print_string = ""
            key_formatted = " ".join([m.group(0).lower() for m in re.finditer('.+?(?:(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|$)', key)])
            print_string = f"{key_formatted:.<25} "
            i = 0
            for v in val:
                if i == 0:
                  val_formatted = format(v, ',').replace(',', ' ').replace('.', ',')
                else:
                  val_formatted = format(v - val[i - 1], ',').replace(',', ' ').replace('.', ',')
                i += 1
                print_string += f"{val_formatted:.>15}:"
            print(print_string)
        print("=" * len(print_string))
        time.sleep(5)
        for key, value in {k: int(v, 16) for k, v in req().json()["result"].items()}.items():
            k = res.get(key, [])
            k.append(value)
            del k[0]
            res[key] = k

if __name__ == "__main__":
  fire.Fire()
