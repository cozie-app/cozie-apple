---
id: downloadData
title: Download Data
sidebar_label: Download Data
---

import useBaseUrl from '@docusaurus/useBaseUrl';

## Download the data collected using the Cozie Apple Watch survey

You can download the data you have collected using the Cozie Apple Watch survey using the following Python code.
Please note that you will have to specify your `USER_ID` and `API_KEY`.
Therefore, it is very important that you have successfully completed Step 5 in [Instructions for testers](installation.md).
You can get these information by emailing us at cozie.app@gmail.com

All the data you have queried are saved inside the Pandas dataframe called `df`.

Keep also in mind that some records (rows of the dataframe) only contain heart rate data.
Consequently if you are interested in analysing only the responses that a participant (USER_ID) provided using the apple watch, please first filter out all the records which contain 'NaN' in the VoteLog column using the following command `df = df.dropna(subset=['voteLog'])`

```
import requests
import json
import pandas as pd

YOUR_TIMEZONE = 'Asia/Singapore'
USER_ID = 'XXXXXXX'
WEEKS = "10"         # Number of weeks from which the data is retrived, starting from now
API_KEY = 'YYYYYY'

payload = {'user_id': USER_ID, 'weeks': WEEKS}

# the api-key below is limited to 200 queries per day. Please contact us to get an API key
headers = {"Accept": "application/json", 'x-api-key': API_KEY}

response = requests.get( 'https://0iecjae656.execute-api.us-east-1.amazonaws.com/default/CozieApple_Read_Influx', params=payload, headers=headers)
data = json.loads(response.content)
df = pd.DataFrame.from_dict(data[1]["data"]).T
df.index = pd.to_datetime(df.index, unit='ms')
df.index = df.index.tz_localize('UTC').tz_convert(YOUR_TIMEZONE)

print(df.head())
```

## Features

| Feature name | Type | Description/Question |
|--------------|------|----------------------|
| `id_participant` | String | Unique identifier for each participant |
| `id_experiment` | String | Unique identifier for each experiment |
| `vote_count` | Integer | Increasing key for each micro-survey response. Resets when Cozie app is (re-)installed. |
| `longitude` | Float | longitude in ° provided by GPS |
| `latitude` | Float | Latitude in ° provided by GPS |
| `body_mass` | Integer | Body mass in kg, provided by Apple Health Kit, only available if manually provided in the Apple Health App. Not used for Osk or Orenth |
| `heart_rate` | Integer | Heart rate in bpm, provided by Apple Health Kit, submitted as background task. Sampled every 5 min (sometimes less) |
| `ts_heartRate` | Integer | Heart rate in bpm, provided by Apple Health Kit, submitted when iPhone Cozie app is opened. Sampled every 5 min (sometimes less) |
| `ts_oxygenSaturation` | Integer | Blood oxygen saturation in % provided by Apple Health Kit |
| `ts_walkingDistance` | Float | Distance walked in m, provided by Apple Health Kit |
| `ts_stepCount` | Integer | Number of steps walked, provided by Apple Health Kit |
| `ts_standTime` | Integer | Stand time in ?, provided by Apple Health Kit |
| `ts_restingHeartRate` | Integer | Resting heart rate in bpm, provided by Apple Health Kit |
| `ts_restingHeartRate` | Float |  Noise level in dB(A), provided by Apple Health Kit, submitted submitted when iPhone Cozie app is opened |
| `sound_pressure` | Integer | Noise level in dB(A), provided by Apple Health Kit, submitted as background task. Sampled every 30 min  |
| `ts_hearingEnvironmentalExposure` | Integer | Noise level in dB(A), provided by Apple Health Kit, submitted when iPhone Cozie app is opened. Sampled every 30min  |
| `timestamp_start` | String | Timestamp (UTC) of when micro survey was started |
| `time` | String | Timestamp (UTC) of when micro survey was submitted, also serves as index (`timestamp_end`) |
| `timestamp_location` | String | Timestamp (UTC) of when the GPS was retrieved |
| `timestamp_lambda` | String | Timestamp (UTC) of when the AWS Lambda function was invoked to insert the row into the database |
| `settings_participation_time_start` | String | Daily reminder start time set in the Cozie app by the participant |
| `settings_participation_time_end` | String | Daily reminder end time set in the Cozie app by the participant |
| `settings_participation_days` | String | Participation days set in the Cozie app by the participant |
| `settings_notification_frequency` | String | Reminder frequency set in the Cozie app by the participant |
| `id_one_signal` | String | Unique OneSignal player id provided by OneSignal |
