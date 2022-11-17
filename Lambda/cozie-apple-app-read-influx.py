# Cozie Apple Read API
# Purpose: Read data from Cozie-Apple app from InfluxDB
# Author: Mario Frei, 2022
# Status: Under development
# Project: Cozie
# Experiemnt: Osk

import json
import datetime
import pandas as pd
from influxdb import InfluxDBClient
import os
from valid_votes import keep_valid_votes

# Influx authentication
user = os.environ["DB_USER"]
password = os.environ["DB_PASSWORD"]
host = os.environ["DB_HOST"]
port = os.environ["DB_PORT"]
db = "cozie-apple"


def lambda_handler(event, context):

    print("Test - asdf - Test")
    measurement = event["queryStringParameters"]["id_experiment"]
    print(f"{measurement=}")

    # Check if there are any parameters, if not 400 error
    if len(event["queryStringParameters"]) == 0:
        return {
            "statusCode": 400,
            "body": json.dumps(
                "query string parameter not defined. Please indicate the experiment-id "
                "in the url string."
            ),
        }

    # Check if experiment_id or participant_id is provided, if not send 400 error
    if ("id_participant" not in event["queryStringParameters"]) or ("id_experiment" not in event["queryStringParameters"]):
        return {
            "statusCode": 400,
            "body": json.dumps("participant_id or experiment_id not in url-string"),
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
    influx_time_horizon = datetime.datetime.strptime(
        "30.06.2022, 00:00", "%d.%m.%Y, %H:%M"
    )
    if time_start < influx_time_horizon:
        time_start = influx_time_horizon

    from_time_str = time_start.strftime("%Y-%m-%dT%H:%M:%SZ")

    # section of the code run if query comes from the cozie apple app
    if "id_participant" in event["queryStringParameters"]:
        
        # Influx client
        client = InfluxDBClient(
            host, port, user, password, db, ssl=True, verify_ssl=True
        )

        # todo query only the columns which do not have timeseries data
        query_influx = """SELECT "id_participant", "id_device", "vote_count", "time", "latitude", "longitude" FROM "{}"."autogen"."{}" WHERE time > '{}' AND id_participant='{}'""".format(
            db, measurement, from_time_str, event["queryStringParameters"]["id_participant"]
        )

        print("query influx: ", query_influx)
        result = client.query(query_influx)
        print("result: ", result)
        last_sync_timestamp = datetime.datetime.now().timestamp()

    try:
        # In order to keep the example on the website working and the app version from the freelancers working there is some adjustment needed to the datetime-index
        # Ideally, the website and app are adapted in order to remove the following lines. (Using the DataFrameClient instead of the InfluxDBClient might resolve this issue)
        df = pd.DataFrame.from_dict(result[measurement])
        print(df.head())
        df["time"] = pd.to_datetime(df["time"])
        df["time"] = df["time"].dt.tz_localize(None)
        df.index = df["time"]
        df = df.drop(["time"], axis=1)
        
        # Remove invalid votes for orenth
        if "orenth" in measurement:
            df = keep_valid_votes(df)
        
        # In order to keep the Cozie app from freezinig for more than 30 seconds the last_sync_timesetamp needs to be returned
        query_influx2 = """SELECT "heart_rate" FROM "{}"."autogen"."{}" WHERE time > '{}' AND id_participant='{}' ORDER BY "time" DESC LIMIT 1 """.format(
            db, measurement, from_time_str, event["queryStringParameters"]["id_participant"]
        )
        result2 = client.query(query_influx2)
        print("----------------------")
        print("result2: ", result2)
        print("----------------------")
        for item in result2[measurement]:
            if '.' in item["time"]:
                last_sync_timestamp = datetime.datetime.strptime(item["time"], "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()
            else:
                last_sync_timestamp = datetime.datetime.strptime(item["time"], "%Y-%m-%dT%H:%M:%SZ").timestamp() # deal with timestamps that don't have decimals

    # no data for that query were available
    except KeyError:
        df = pd.DataFrame()

    field1 = event["queryStringParameters"]
    field1["last_sync_timestamp"] = last_sync_timestamp

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
