# Create usage plan and API key for AWS API Gateway

## Create Usage Plan

Create Usage Plan using the following command, please change the name, description and throttle.
```
aws apigateway create-usage-plan \
    --name "cozie-apple-app-<researcher ID/experiment ID>-usage-plan" \
    --description "<A new usage plan>" \
    --throttle burstLimit=1000,rateLimit=1000 \
    --quota limit=2000,offset=0,period=DAY \
    --api-stage apiId=wifmmwu7qe,stage=default
```

Create API key
```
aws apigateway create-api-key \
    --name 'cozie-apple-app-<researcher ID/experiment ID>-key' \
    --description 'Description of who is using the key' \
    --enabled
```

Associate the key to the usage plan
```
aws apigateway create-usage-plan-key \
    --usage-plan-id <ID of the usage plan you got from the Usage Plan generation> 
    --key-type "API_KEY" \
    --key-id <key ID you got from the API key generation>
```
