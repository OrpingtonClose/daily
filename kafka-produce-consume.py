#https://docs.confluent.io/3.0.0/clients/confluent-kafka-python/

from confluent_kafka import Consumer, TopicPartition, Producer
import sys
import json

conf = {  'bootstrap.servers': "...", 
                'broker.version.fallback': '0.10.0.0',
                'api.version.fallback.ms': 0,
                'sasl.mechanisms': 'PLAIN',
                'security.protocol': 'SASL_SSL',
                'group.id': "test-group", 
                'session.timeout.ms': 6000,
                'auto.offset.reset': 'earliest',
                'sasl.username':'...',
                'sasl.password':'...',
                'auto.offset.reset': 'earliest'}

topic_name = "test-topic"

def consume():

    c = Consumer(conf)

    num_partitions = len(c.list_topics().topics[topic_name].partitions)
    topic_partitions = []
    for partition_index in range(0, num_partitions-1):
        topic_partition = TopicPartition(topic_name, partition_index, 0)
        topic_partitions.append(topic_partition)

    c.subscribe([topic_name])
    c.assign(topic_partitions)

    while True:
        msg = c.poll(5)
        if msg is None:
            continue
        if msg.error():
            raise KafkaException(msg.error())
        else:
            print(msg.value())

def produce():
    
    #https://random-word-api.herokuapp.com/word?number=10
    #r = requests.get('http://api.nbp.pl/api/exchangerates/tables/A?format=json')
    #r = requests.get('https://random-word-api.herokuapp.com/word?number=10')

    producer = Producer(conf)

    for n in range(10):
        record_key = "alice"
        record_value = json.dumps({'count': n})
        producer.produce(topic_name, key=record_key, value=record_value)#, on_delivery=acked)
        # p.poll() serves delivery reports (on_delivery)
        # from previous produce() calls.
        producer.poll(0)

    producer.flush()

produce()
consume()
