from flask import Flask, jsonify
import random
import datetime

app = Flask(__name__)

@app.route('/sensor')
def sensor():
    data_list = []

    for i in range(50):
        data = {
            "asset_id": "PUMP-01",
            "vibration_mm_s": round(random.uniform(2.5, 6.5), 2),
            "temperature_c": round(random.uniform(55, 90), 1),
            "motor_current_a": round(random.uniform(15, 25), 1),
            "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        data_list.append(data)


    return jsonify(data_list)

app.run(port=5000)
