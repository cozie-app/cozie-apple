---
id: notifications
title: Send Notifications with OneSignal
sidebar_label: iOS - Push notifications
---

import useBaseUrl from '@docusaurus/useBaseUrl';

Please follow the instructions in the video below to learn more on how to send notifications with OneSignal.

<iframe width="100%" height="315" src="https://www.youtube.com/embed/KgJbdKgmtsQ" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowFullScreen></iframe>

## Sending custom notifications

You can send custom notifications to users by using the following code. You will need to specify your `authorization` key in the header and the `app_id` in the payload. You can then set filters and target specific users as shown in the example below. You can read more about the different types of filter on the OneSignal [official documentation website](https://documentation.onesignal.com/reference/create-notification#example-code---create-notification).

```python
import requests
import json

header = {"Content-Type": "application/json; charset=utf-8",
          "Authorization": "Basic xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}

payload = {"app_id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
           "filters": [
                {"field": "country", "relation": "=", "value": "SG"},
                {"operator": "AND"}, {"field": "app_version", "relation": "=", "value": "15"}
            ],
           "included_segments": ["All"],
           "contents": {"en": "Please complete the Cozie survey, app version 15."}}

req = requests.post("https://onesignal.com/api/v1/notifications", headers=header, data=json.dumps(payload))

print(req.status_code, req.reason)
```