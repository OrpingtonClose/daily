#event hub and raspberry pi, low level
#how to install the azure.http package?
#http://blog.faister.com/2014/11/26/how-to-send-sensor-data-from-raspberry-pi-to-azure-event-hub-using-a-python-script/

#event hubs in c lang. SSL error error
#guess something of this sort is to be tried first:
#https://docs.microsoft.com/en-gb/azure/iot-hub/iot-hub-x509ca-overview
#https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-c-getstarted-send

#the easiest and actually works!
#https://www.jamessturtevant.com/posts/using-azure-python-sdk-with-event-hubs/

def send_msg_bus(namespace, hub, user, password):
  from azure.servicebus import ServiceBusService, Message, Queue
  from datetime import datetime
  import subprocess
  bus_service = ServiceBusService(service_namespace=namespace, 
                                  shared_access_key_name=user, 
                                  shared_access_key_value=password)
  message = subprocess.getoutput('az resource list -o json')
#  message = 'mon script,"{}"'
  bus_service.send_event(hub, message)

#https://github.com/Azure/azure-event-hubs-python/blob/master/examples/send.py
def send_msg(addr, user, password):
  from azure.eventhub import EventHubClient, Sender, EventData
  client = EventHubClient(addr, username=user, password=password)
  sender = client.add_sender(partition='1')
  client.run()
  try:
    from datetime import datetime
    current_time = datetime.now().isoformat()
    message = "hi from event hub {}".format(current_time)
    event_data = EventData(message)
    sender.send(event_data)
  except:
    raise
#  return client
  finally:
    client.stop()

if __name__ == '__main__':
  import argparse
  parser = argparse.ArgumentParser()
  parser.add_argument('namespace')
  parser.add_argument('hub')
  parser.add_argument('policy')
  parser.add_argument('password')
  args = parser.parse_args()
  ns = args.namespace
  hub = args.hub
  policy = args.policy
  password = args.password
  from time import sleep
  import random
  n = 1
  for _ in range(100):
    print('.'*n)
    n = 0 if n > 20 else n + 1
    sleep(1)
    send_msg_bus(ns, hub, policy, password)
  
#  send_msg(addr, policy, password)

