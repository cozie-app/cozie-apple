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
