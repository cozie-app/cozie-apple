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
let AWSReadURL = "https://wifmmwu7qe.execute-api.ap-southeast-1.amazonaws.com/development/cozie-apple-app-read-influx"
let AWSWriteAPIKey = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
let AWSReadAPIKey = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"

let OneSignalAppID = "be00093b-ed75-4c2e-81af-d6b382587283"
