# Issue #104: Settings Synchronization


## 1. Background 

After installing Cozie, users sometimes cannot sync settings between the phone and watch apps. This can happen on physical devices and simulators. The existing troubleshooting steps do not always resolve it.

## 2. Causes Found 

1. The original settings sync relied on immediate messages through `sendMessage()`. When the watch was temporarily unreachable, the code did not reliably retry delivery after the connection recovered. It also treated a successfully activated but unreachable session as a failure.
   
2. The watch replied before checking and saving settings. Some preparation errors, such as an empty survey link or a database save failure, did not return a completion result. These weaknesses could cause premature success reports or leave the interface waiting.

3. A separate simulator problem was observed during testing: the pair appeared active, but the underlying communication service reported “No pair is active.” 

## 3. Sync Process

1. The user presses Sync beside Experiment Settings in the phone app. The phone downloads the selected survey and reads the current settings.

2. The phone validates the data, adds a revision identifier and timestamp, and saves the latest complete settings snapshot locally. The snapshot is a copy of the settings, not a history of survey answers.

3. After session activation, the phone submits the snapshot through `updateApplicationContext()`. If this succeeds and the watch is reachable, it also sends the same snapshot through `sendMessage()` for faster delivery. A context submission error ends the current attempt with an error.

4. The watch processes both delivery methods through the same receiving logic. It validates the settings, checks the revision and timestamp, saves valid settings, and prepares the questionnaire. The revision identifies duplicates; the timestamp helps prevent older settings from overwriting newer ones.
  
5. The watch returns the processing result with the revision identifier. The phone only accepts a confirmation matching its current snapshot before reporting success.

6. If no confirmation arrives within 20 seconds of the sending stage, the phone ends the loading state and reports pending delivery. The saved snapshot remains available for later attempts. Connection-related events and app startup can trigger another attempt. This timeout does not include survey downloading or guarantee delivery within 20 seconds.

## 4. Testing and Limitations 

1. Manual end-to-end simulator testing of the current code has passed. Selecting and syncing a different survey on the phone successfully updated the questionnaire on the paired watch, confirming a new settings update rather than only displaying a previously saved questionnaire.

2. Physical-device testing and first-install testing are still pending. Both apps should be updated together because the new phone expects a versioned acknowledgement. Issue #104 is not yet fully verified, and physical-device testing remains the priority.
