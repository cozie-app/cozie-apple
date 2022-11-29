---
id: downloadData
title: Download Data
sidebar_label: Download Data
---

import useBaseUrl from '@docusaurus/useBaseUrl';

## Download the data collected using the Cozie Apple Watch survey

You can download the data you have collected using the Cozie Apple Watch survey using the following Python code.
Please note that you will have to specify your `ID_PARTICIPANT`, `ID_EXPERIMENT` and `API_KEY`.
Therefore, it is very important that you have successfully completed Step 5 in [Instructions for testers](installation.md).
You can get these information by emailing us at cozie.app@gmail.com

All the data you have queried are saved inside the Pandas dataframe called `df`.

```
import requests
import json
import pandas as pd
import matplotlib.pyplot as plt

# Settings
YOUR_TIMEZONE = 'Asia/Singapore'
ID_PARTICIPANT = 'ExternalUser'
ID_EXPERIMENT = 'AppleStore'
WEEKS = "2"  # Number of weeks from which the data is retrived, starting from now
API_KEY = '' # reach out to cozie.app@gmail.com for an API_KEY

# Query data
payload = {'id_participant': ID_PARTICIPANT,'id_experiment': ID_EXPERIMENT, 'weeks': WEEKS}
headers = {"Accept": "application/json", 'x-api-key': API_KEY}
response = requests.get('https://m7cy76lxmi.execute-api.ap-southeast-1.amazonaws.com/default/cozie-apple-researcher-read-influx', params=payload, headers=headers)
data = json.loads(response.content)

# Convert response in Pandas Dataframe
df = pd.DataFrame.from_dict(data).T
df.index = pd.to_datetime(df.index, unit='ms')
df.index = df.index.tz_localize('UTC').tz_convert(YOUR_TIMEZONE)
pd.options.display.max_columns = None

# Display dataframe
df.head()
```

### Watch survey data
If you want to focus on the analysis of the watch-based survey data use the code below to filter the dataframe retrieved above.

```
# Get only question flow responses
df_questions = df[~df["vote_count"].isna()]
df_questions.style
```

### Physiological data
Use the code below to plot noise and heart rate data contained in the dataframe retrieved above. 

```
# Plot time-series data
fig, ax = plt.subplots(1,2, figsize =(15, 7))

# Heart rate
df["heart_rate"].plot(ax=ax[0], style='.')
ax[0].set_title("Heart Rate", fontsize=18)
ax[0].set_ylabel("Heart Rate [bpm]", fontsize=14)
ax[0].set_xlabel("Time", fontsize=14)

# Sound pressure
df["sound_pressure"].plot(ax=ax[1], style='.')
ax[1].set_title("Sound Pressure", fontsize=18)
ax[1].set_ylabel("Sound Pressure [dB?]", fontsize=14)
ax[1].set_xlabel("Time", fontsize=14)
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
