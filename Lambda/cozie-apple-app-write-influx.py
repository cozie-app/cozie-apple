# Cozie Apple Write API
# Purpose: Insert data from Cozie-Apple app to InfluxDB
# Author: Mario Frei, 2022
# Status: Under development
# Project: Cozie

import os
import json
from influxdb import InfluxDBClient, DataFrameClient
import time
from datetime import datetime
from pprint import pprint
import requests
from check_type import check_type

# influx authentication
user = os.environ['DB_USER']
password = os.environ['DB_PASSWORD']
host = os.environ['DB_HOST']
port = os.environ['DB_PORT']
db = "cozie-apple"

def lambda_handler(event, context):

    # Forward request to node red
    try:
        print("Forward request to old Node-Red server:")
        node_red_url = "http://ec2-52-76-31-138.ap-southeast-1.compute.amazonaws.com:1880/cozie-apple"
        payload =  json.loads(event['body'])
        response = requests.post(node_red_url, json=payload)
        print(response.content)
        print("---------------------------")
    except:
        print("Forward request to old Node-Red server failed.")    

    # Influx client
    client = InfluxDBClient(host, port, user, password, db, ssl=True, verify_ssl=True)

    # Read payload
    payload = json.loads(event['body'])
    pprint(payload)
    
    # Reject old id_experiments
    deprecated_experiments = ["shen",
                              "senth",
                              "nen",
                              "nern",
                              "resh"]
    
    if payload['id_experiment'] in deprecated_experiments:
        print("id_experiment is", payload['id_experiment'], "That Cozie version is outdated and payloads are not parsed correctly. Hence all data is rejected in order to make the logs more readable.")
    
    # Check for minimal presence of required fields/tags
    required_keys = ['id_participant', 'timestamp_end', 'id_experiment']
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
    # Get timestmap from call of lambda function
    timestamp_lambda = datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    
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
        elif key == 'heart_rate' or 'ts_' in key or key == 'sound_pressure':  # in key:
            for key_ts in payload[key].keys():
                timestamp_ts = key_ts
                print("key_ts: ", key_ts, "timestamp_ts: ", timestamp_ts, "timestamp_test", int(time.time()))

                value_checked = check_type(key, payload[key][key_ts])
                    
                json_body.append({
                    'time': timestamp_ts,  # XXX
                    'measurement': payload['id_experiment'],
                    'tags': {
                        'id_participant': payload['id_participant'],
                        'id_device': payload['id_device']
                        },
                    'fields': {
                        key: value_checked,
                        'timestamp_lambda': timestamp_lambda       
                    }
                    })
        else:
            fields[key] = check_type(key, payload[key])
        print("---------------------")

    # Convert timestamp from string to

    timestamp = payload['timestamp_end']  # for debugging
    print("timestamp_end: ", payload['timestamp_end'])
    fields["timestamp_lambda"] = timestamp_lambda
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
    feedback = client.write_points(json_body, batch_size=5000)  # write to InfluxDB
    print("Client write: ", feedback)
    print("##########################################################")

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
            },
        "body": "Success"
        }