cd into the function directory
```
cd '.\Google Cloud Functions\get_cozie_data_influx\'
```

Deploy the function

```
gcloud functions deploy get_cozie_data_influx --runtime python38 --trigger-http --allow-unauthenticated --project testbed-310521
```

Get information about the function that is running
```
gcloud functions describe get_cozie_data_influx --project testbed-310521
```

View logs
```
gcloud functions logs read get_cozie_data_influx --project testbed-310521
```

Testing the function, more info [here](https://github.com/GoogleCloudPlatform/functions-framework-python)
```bash
functions-framework --target get_cozie_data_influx --debug
```

Python code to query the data
```python
import pandas as pd
import json
import requests

YOUR_TIMEZONE = 'Asia/Singapore'
USER_ID = 'VVeuFDZkVzObhRgZkA6UuSnrBCF2'
LIMIT = 1000

payload = {'userid': USER_ID, 'limit': LIMIT}

response = requests.get( 'https://us-central1-testbed-310521.cloudfunctions.net/get_cozie_data_influx', params=payload)
my_json = response.content.decode('utf8')
data = json.loads(my_json)
df = pd.DataFrame.from_dict(data).T
df.index = pd.to_datetime(df.index.astype("int64"),unit='ms')
df.index = df.index.tz_localize('UTC').tz_convert(YOUR_TIMEZONE)

print(df.sort_values(["voteLog"], ascending=False).head())
```