# Cozie Apple Write API
# Purpose: Insert data from Cozie-Apple app to InfluxDB
# Author: Mario Frei, 2022
# Status: Under development
# Project: Cozie

import os
import json
from influxdb import InfluxDBClient, DataFrameClient
import time
from pprint import pprint

# influx authentication
user = os.environ['DB_USER']
password = os.environ['DB_PASSWORD']
host = os.environ['DB_HOST']
port = os.environ['DB_PORT']
db = "cozie-apple"

def lambda_handler(event, context):

    # # Forward request to node red
    # print("Forward request to old Node-Red server:")
    # node_red_url = "http://ec2-52-76-31-138.ap-southeast-1.compute.amazonaws.com:1880
    # /cozie-apple"
    # payload =  json.loads(event['body'])
    # response = requests.post(node_red_url, json=payload)
    # print(response.content)
    # print("---------------------------")

    # Influx client
    client = InfluxDBClient(host, port, user, password, db, ssl=True, verify_ssl=True)

    # Read payload
    payload = json.loads(event['body'])
    pprint(payload)

    # Check for minimal presence of required fields/tags
    required_keys = ['id_participant', 'timestamp_end']
    for key_required in required_keys:
        if key_required not in payload:
            print(f"Either the {required_keys} were not in the payload")
            return {
                "statusCode": 500,
                "headers": {
                    "Content-Type": "application/json"
                    },
                "body": "Error: Required fields or tags ar missing"
                }

    # Check for fields
    fields = {}
    json_body = []
    tags = ['id_participant', 'id_device', 'id_experiment', 'timestamp_end']

    for key in payload.keys():
        # Check if the key value is an integer or a float
        print("# Key: ", key)
        if key in tags:
            # print('tag')
            pass
        elif key == 'responses':
            # print("responses")
            for key_r in payload[key].keys():
                fields[key_r] = payload[key][key_r]
        elif key == 'heart_rate' or key == 'ts_' or key == 'sound_pressure':  # in key:
            for key_ts in payload[key].keys():
                timestamp_ts = key_ts
                print("key_ts: ", key_ts, "timestamp_ts: ", timestamp_ts, "timestamp_test", int(time.time()))
                json_body.append({
                    'time': timestamp_ts,  # XXX
                    'measurement': payload['id_experiment'],
                    'tags': {
                        'id_participant': payload['id_participant'],
                        'id_device': payload['id_device']
                        },
                    'fields': {key: payload[key][key_ts]}
                    })
        else:
            # print("other")
            # if isinstance(payload[key], int):
            #     payload[key] = float(payload[key])  # This conversion is needed because there is already
            #     # float-type data in the database for some of the fields.
            fields[key] = payload[key]
        print("---------------------")

    # Convert timestamp from string to
    # timestamp = int(datetime.strptime(payload['timestamp_end'],
    # "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()*1000*1000)  # Can be removed
    timestamp = payload['timestamp_end']  # for debugging
    print("timestamp_end: ", payload['timestamp_end'])
    json_body.append({
        'time': timestamp,
        'measurement': payload['id_experiment'],
        'tags': {
            'id_participant': payload['id_participant'],
            'id_device': payload['id_device']
            },
        'fields': fields
        })

    print("##########################################################")
    print("json_body:")
    # print(type(json_body))
    print(json.dumps(json_body, indent=4))
    print("##########################################################")
    feedback = client.write_points(json_body)  # write to InfluxDB
    print("Client write: ", feedback)
    print("##########################################################")

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
            },
        "body": "Success"
        }