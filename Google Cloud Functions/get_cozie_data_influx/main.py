from flask import escape
import json
import datetime
import pandas as pd
from influxdb import DataFrameClient
from influxdb.exceptions import InfluxDBClientError
import functions_framework


@functions_framework.errorhandler(InfluxDBClientError)
def special_exception_handler(e):
    return (
        json.dumps(
            {
                "success": False,
                "body": "Database connection failed, please contact us at cozie.app@gmail.com",
                "error": str(e),
            }
        ),
        500,
        {"ContentType": "application/json"},
    )


@functions_framework.errorhandler(KeyError)
def no_data_available(e):
    return (
        json.dumps(
            {
                "success": False,
                "body": "No data for that specific user are available in the selected time period. "
                "Please ensure you have entered the correct userid. "
                "If you have any questions please contact us at cozie.app@gmail.com",
                "error": str(e),
            }
        ),
        500,
        {"ContentType": "application/json"},
    )


def get_from_time_string(weeks):
    now = datetime.datetime.utcnow()
    # the time x weeks ago
    time_ago = now - datetime.timedelta(weeks=weeks)
    from_time_str = time_ago.strftime("%Y-%m-%dT%H:%M:%SZ")
    return from_time_str


def get_data(userid, weeks=1, limit=5):
    client = DataFrameClient(
        "lonepine-64d016d6.influxcloud.net",
        8086,
        "google-cloud-function",
        "81fD99W9ItD@3k",
        "testingDB",
        ssl=True,
        verify_ssl=True,
    )

    # Set time strings to query data from influx
    from_time_str = get_from_time_string(weeks=weeks)

    result = client.query(
        f"SELECT * FROM testingDB.autogen.cozieApple WHERE time > '{from_time_str}'"
        f"AND user_id='{userid}' LIMIT {limit}"
    )

    cozie_df = pd.DataFrame.from_dict(result["cozieApple"])

    return cozie_df.to_json(orient="index")


def parse_args(key, default_value, request_json, request_args):
    if request_json and key in request_json:
        key = request_json[key]
    elif request_args and key in request_args:
        key = request_args[key]
    else:
        key = default_value
    return key


def get_cozie_data_influx(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <https://flask.palletsprojects.com/en/1.1.x/api/#incoming-request-data>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response>.
    """
    request_json = request.get_json(silent=True)
    request_args = request.args

    limit = parse_args("limit", 100, request_json, request_args)
    weeks = parse_args("weeks", 2, request_json, request_args)
    userid = parse_args("userid", False, request_json, request_args)

    if userid:
        return str(get_data(userid, weeks=weeks, limit=limit))
    else:
        return (
            json.dumps(
                {
                    "success": False,
                    "body": "Please indicate the userid in the query string of the user you would like to query the data."
                    "For example: https://us-central1-testbed-310521.cloudfunctions.net"
                    "/get_cozie_data_influx?userid=xxxxxxxxxxxx",
                }
            ),
            400,
            {"ContentType": "application/json"},
        )
