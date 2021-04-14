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