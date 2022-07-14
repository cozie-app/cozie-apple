//
//  Constant.swift
//  Cozie
//
//  Created by Square Infosoft on 28/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

let defaultFromTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
let defaultToTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
let defaultNotificationFrq = Calendar.current.date(bySettingHour: 1, minute: 0, second: 0, of: Date()) ?? Date()
let defaultExperimentID = "AppleStore"
let defaultParticipantID = "ExternalTester"

let primaryColour = UIColor(named: "primaryColour")

let imgGithub = "githubLogo"
let imgBudsLab = "budsLabIcon"
let imgDownload = "downloadData"
let folderName = "Cozie"

let AWSWriteURL = "https://wifmmwu7qe.execute-api.ap-southeast-1.amazonaws.com/development/cozie-apple-app-write-influx"
let AWSReadURL = "https://wifmmwu7qe.execute-api.ap-southeast-1.amazonaws.com/default/cozie-apple-app-read-influx"
let AWSWriteAPIKey = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
let AWSReadAPIKey = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"

let OneSignalAppID = "4d2b287e-603c-47db-a2b8-80b2a5d93473"
