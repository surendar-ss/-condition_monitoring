import json
import random
import datetime
import time
import paho.mqtt.client as mqtt

client = mqtt.Client()
client.connect("localhost", 1883)

while True:
    data = {
        "asset_id": "PUMP-01",
        "vibration_mm_s": round(random.uniform(2.5, 6.5), 2),
        "temperature_c": round(random.uniform(55, 90), 1),
        "motor_current_a": round(random.uniform(15, 25), 1),
        "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    }

    client.publish("plant/pump01/sensor", json.dumps(data))
    print("Published:", data)

    time.sleep(5)
