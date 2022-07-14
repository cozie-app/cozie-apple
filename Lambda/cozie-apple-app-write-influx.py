# Cozie Apple Write API
# Purpose: Insert data from Cozie-Apple app to InfluxDB
# Author: Mario Frei, 2022
# Status: Under development
# Project: Cozie
# Experiemnt: Osk

# To Do:
#  - clean up field names (make json payload and database fields equal)
#  - Add error handling

import os
import json
from influxdb import InfluxDBClient, DataFrameClient
import time
import logging
from pprint import pprint

# influx authentication
user = os.environ['DB_USER']
password = os.environ['DB_PASSWORD']
host = os.environ['DB_HOST']
port = os.environ['DB_PORT']
db = os.environ['DB_NAME']
measurement = os.environ['DB_MEASUREMENT']  # sql-table equivalent in InfluxDB


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
    required_keys = ['participantID', 'endTimestamp']
    for key_required in required_keys:
        if key_required not in payload:
            print(f"Either of the following keys was not in the payload")
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
    tags = ['participantID', 'deviceUUID', 'user_id', 'experiment_id', 'endTimestamp']

    for key in payload.keys():
        # Check if the key value is an integer or a float
        print("---------------------")
        print("Key: ", key)
        if key in tags:
            print('tag')
        elif key == 'responses':
            print("responses")
            for key_r in payload[key].keys():
                fields[key_r] = payload[key][key_r]
        elif key == 'heartRate' or key == 'ts_' or key == 'noiseWatch':  # in key:
            print("timeseries")
            for key_ts in payload[key].keys():
                timestamp_ts = key_ts  # int(datetime.strptime(key_ts,
                # "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()*1000*1000*1000)   # Can be removed
                print("key_ts: ", key_ts)
                print("timestamp_ts: ", timestamp_ts)
                print("timestamp_test", int(time.time()))
                # timestamp_ts = 'xxx' # for debugging
                fields_ts = {}
                if (key == 'heartRate'):
                    fields_ts[key] = float(payload[key][
                        key_ts])  # This is necesssary because heartRate has been
                    # stored as a float before can be removed when data is stored in a
                    # new table
                else:
                    fields_ts[key] = payload[key][key_ts]
                json_body.append({
                    'time': timestamp_ts,  # XXX
                    'measurement': measurement,
                    'tags': {
                        'user_id': payload['participantID'],
                        'device_uuid': payload['deviceUUID']
                        },
                    'fields': fields_ts
                    })
        else:
            print("other")
            if isinstance(payload[key], int):
                payload[key] = float(payload[
                    key])  # This conversion is needed because there is already
                # float-type data in the database for some of the fields.
            fields[key] = payload[key]
        print("---------------------")

    # Convert timestamp from string to
    # timestamp = int(datetime.strptime(payload['endTimestamp'],
    # "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()*1000*1000)  # Can be removed
    timestamp = payload['endTimestamp']  # for debugging
    print("endTimestamp: ", payload['endTimestamp'])
    json_body.append({
        'time': timestamp,
        'measurement': measurement,
        'tags': {
            'user_id': payload['participantID'],
            'device_uuid': payload['deviceUUID']
            },
        'fields': fields
        })

    print("##########################################################")
    print("json_body:")
    print(type(json_body))
    # print(json_body)
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