---
id: privacyPolicy
title: Cozie Privacy Policy
sidebar_label: Privacy policy
---

# Privacy Statement


## Purpose

The aim of the mobile application “Cozie” is to demonstrate the use of the Apple Watch and iPhone for micro Environmental Momentary Assessments (uEMA). The app as it is available on the App Store is for demonstration purposes only. People interested in the uEMA can use the app to explore the technology, its usefulness, and quality of the collected data. If Cozie is to be used beyond demonstration purposes, we suggest that you fork the source code and deploy your own version of Cozie together with your own database and backend. All source code is available at <https://github.com/cozie-app/cozie-apple>. Documentation is available at <https://cozie-apple.app/>. 

## Data Collection

The Cozie app does not explicitly collect any personal data. It is designed to collect measurement data without any relation to individuals. However, in some circumstances, this data can bear a connection to personal data. For example, GPS data can exhibit a location.

All data that the Cozie app collects is listed below. 

- Physiological Data
  - Body mass
  - Heart Rate
  - Blood Pressure
  - Noise
  - BMI
  - Blood Oxygen Saturation
  - Step Count
  - Stand Time
  - Walking Distance
  - Resting Heart Rate
- Micro-survey
  - Time at the start of the micro-survey
  - Time at the end of the micro-survey
  - Location (longitude, latitude)
  - Responses
- Weekly survey
  - Responses
- Settings
  - Experiment ID
  - Participant ID
  - Participation start time
  - Participation end time
  - Participation days
  - Notification frequency
  - Build number
  - Bundle Version
  - App name
  - OneSignal Player ID (3rd party push notification service)

Users of the Cozie app will be asked to provide permission to share physological data and location data. Users can revoke the permission in the Settings app and/or in the Health app from Apple.

All data transmitted by the Cozie app to the Database and requested by the Cozie app from the database is transmitted using HTTPS requests. All data transmitted by the Cozie app is stored in a password protected database. The data in the database is stored in clear text. All data transmitted to the database is tagged with the “experiment ID” and “participant ID”.

The data in the database can be retrieved using web API calls as shown in the documentation. Only the “experiment ID” and the ”participant ID” are required to retrieve any data that is associated with those two identifiers. Hence, the “experiment ID” and “participant ID” have password character and should not be shared with anyone.

## Data Storage

The database and related services are located in Singapore.

The data will be not be deleted on a regular basis. However, we reserve the right to delete any data submitted with the Cozie app at any time.

## Data Processing

The data is used for the purpose of improving the Cozie app and the accompanying documentation website.

## 3rd Party Services

Cozie uses OneSignal as the provider of push notification services. Please see their privacy policy for more information: https://onesignal.com/privacy_policy

