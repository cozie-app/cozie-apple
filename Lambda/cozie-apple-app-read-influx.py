# Cozie Apple Read API
# Purpose: Read data from Cozie-Apple app from InfluxDB
# Author: Mario Frei, 2022
# Status: Under development
# Project: Cozie
# Experiemnt: Osk

import json
import datetime
import pandas as pd
import numpy as np
from influxdb import InfluxDBClient
import os


def lambda_handler(event, context):

    # Influx authentication
    user = os.environ['DB_USER']
    password = os.environ['DB_PASSWORD']
    host = os.environ['DB_HOST']
    port = os.environ['DB_PORT']
    db = os.environ['DB_NAME']
    measurement = os.environ['DB_MEASUREMENT']  # sql-table equivalent in InfluxDB
    # measurement = "cozieApple_debug" # For debugging

    # Check if there are any parameters, if not 400 error
    if (len(event["queryStringParameters"]) == 0):
        return {
            "statusCode": 400,
            "body": json.dumps(
                "query string parameter not defined. Please indicate the experiment-id "
                "in the url string."
                ),
            }

    # Check if experiment-id is provided, if not send 400 error
    if "user_id" not in event["queryStringParameters"]:
        return {
            "statusCode": 400,
            "body": json.dumps("participant-id not in url-string"),
            }

    # Select the number of weeks to query data: Default is 2 weeks
    if "weeks" in event["queryStringParameters"]:
        weeks = float(event["queryStringParameters"]["weeks"])
    else:
        weeks = 2

    # Set time strings to query data from influx
    now = datetime.datetime.utcnow()  # Set time strings to query data from influx
    time_start = now - datetime.timedelta(weeks=weeks)  # Get the time x weeks ago

    # Limit start time of data to be retrieved
    # This hack is needed because some fault data was inserted on 29.03.2022. All queries including data from data they return empty. The exact reason is unkown.
    influx_time_horizon = datetime.datetime.strptime("30.03.2022, 00:00",
        "%d.%m.%Y, %H:%M")
    if time_start < influx_time_horizon:
        time_start = influx_time_horizon

    from_time_str = time_start.strftime("%Y-%m-%dT%H:%M:%SZ")

    # query the entire database and return in pandas compatible format
    if "user_id" in event["queryStringParameters"]:
        # Influx client
        client = InfluxDBClient(host, port, user, password, db, ssl=True, verify_ssl=True)

        query_influx = "SELECT * FROM testingDB.autogen.{} WHERE time > '{}' AND user_id='{}'".format(
            measurement, from_time_str,
            event["queryStringParameters"]["user_id"])  # Original query

        # Restrict query so that the resulting dataframe does not exceed the 6MB limit of AWS Lambda

        # query_influx = "SELECT \"user_id\", \"device_uuid\",\"voteLog\", \"end\",
        # \"clo\", \"location-place\", \"location-in-out\", \"tc-preference\", \"met\",
        # \"any-change\", \"last-60min\", \"alone-group\", \"surroundings-infection\"
        # FROM testingDB.autogen.cozieApple WHERE time > '{}' AND user_id='{}'".format(
        # from_time_str, event["queryStringParameters"]["user_id"])

        query_influx = """SELECT 
                          \"user_id\", \"device_uuid\",\"voteLog\", \"end\", \"clo\", \"location-place\", \"location-in-out\", \"tc-preference\", \"met\", \"any-change\", \"last-60min\", \"alone-group\", \"surroundings-infection\", 
                          \"surroundings-infection\", \"within-5m\", \"cause-risk\", \"concerns\", 
                          \"tc-preference\", \"light-preference\", \"sound-preference\", \"are-you\", \"location-place \", \"near-sensor?\", \"mood\", \"clo\", \"changed-loaction\", 
                          \"alone-group\", \"activity\", \"distracting\", \"distractions\", \"activity\", \"more-privacy\", \"kind-distraction\", \"why-more-privacy\", \"what-privacy\", \"people-see\", \"activity\", \"surroundings-infection\", \"within-5m\", \"cause-risk\", \"concerns\", 
                          \"last-60min\", \"lift-why\", \"stairs-why\", \"lift-con\", \"stairs-con\", \"working\", \"workstation\", \"adj-height\", \"current\", \"lift-why\", \"stairs-why\", \"lift-con\", 
                          \"latitude\", \"longitude\",
                          \"How much fatigue have you been experiencing throught the week?\", \"How much fatigue are you currently experiencing?\", \"On which days did you work from home this week?\", \"Please indicate your satisfaction levels with the overall indoor air quality in your office.\", \"Are you experiencing any of the following symptoms? (Select all that apply)\" 
                          FROM testingDB.autogen.{} WHERE time > '{}' AND user_id='{}'""".format(
            measurement, from_time_str, event["queryStringParameters"]["user_id"])
        # \"locationTimestamp\", \"latitude\", \"longitude\", \"endTimestamp\", \"startTimestamp\",
        # The following a hack upon request from the freelancers: \"latitude\", \"longitude\",
        print(query_influx)
        result = client.query(query_influx)
        print("----------------------")
        print("result")
        print(result)
        print("----------------------")
        last_sync_timestamp = datetime.datetime.now().timestamp()

    try:
        # In order to keep the example on the website working and the app version from the freelancers working there is some adjustment needed to the datetime-index
        # Ideally, the website and app are adapted in order to remove the following lines. (Using the DataFrameClient instead of the InfluxDBClient might resolve this issue)
        df = pd.DataFrame.from_dict(result["cozieApple"])
        df['time'] = pd.to_datetime(df['time'])
        df['time'] = df['time'].dt.tz_localize(None)
        df.index = df['time']
        df = df.drop(['time'], axis=1)

        # In order to keep the Cozie app from freezinig for more than 30 seconds the last_sync_timesetamp needs to be returned
        query_influx2 = """SELECT "heartRate" FROM "testingDB"."autogen"."{}" WHERE time > '{}' AND user_id='{}' ORDER BY "time" DESC LIMIT 1 """.format(
            measurement, from_time_str, event["queryStringParameters"]["user_id"])
        result2 = client.query(query_influx2)
        print("----------------------")
        print("result2")
        print(result2)
        print("----------------------")
        for item in result2["cozieApple"]:
            last_sync_timestamp = datetime.datetime.strptime(item["time"],
                '%Y-%m-%dT%H:%M:%S.%fZ').timestamp()

    # no data for that query were available
    except KeyError:
        df = pd.DataFrame()

    field1 = event["queryStringParameters"]
    field1['last_sync_timestamp'] = last_sync_timestamp

    df_json = df.to_json(orient="index")
    df_dict = json.loads(df_json)

    # hack for freelancesrs
    for key in df_dict:
        df_dict[key]["timestamp"] = key

    json_body = [
        field1,
        {"data": df_dict},
        ]
    print("------------------------")
    print("json_body:")
    print(json_body)
    print("------------------------")

    return {"statusCode": 200, "body": json.dumps(json_body)}