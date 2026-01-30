import json
import mysql.connector
import paho.mqtt.client as mqtt

db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="admin123",
    database="condition_monitoring"
)
cursor = db.cursor()

def on_message(client, userdata, msg):
    data = json.loads(msg.payload)

    sql = """
    INSERT INTO sensor_readings
    (asset_id, vibration_mm_s, temperature_c, motor_current_a, reading_time)
    VALUES (%s, %s, %s, %s, %s)
    """
    values = (
        data["asset_id"],
        data["vibration_mm_s"],
        data["temperature_c"],
        data["motor_current_a"],
        data["timestamp"]
    )
    cursor.execute(sql, values)
    db.commit()
    print("Inserted:", data)

client = mqtt.Client()
client.connect("localhost", 1883)
client.subscribe("plant/pump01/sensor")
client.on_message = on_message

client.loop_forever()
