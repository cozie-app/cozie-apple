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
let defaultExperimentID = "trill"
let defaultParticipantID = "trill"

let primaryColour = UIColor(named: "primaryColour")

let imgGithub = "githubLogo"
let imgBudsLab = "budsLabIcon"
let imgDownload = "downloadData"
let folderName = "Cozie"

let AWSWriteURL = "https://wifmmwu7qe.execute-api.ap-southeast-1.amazonaws.com/development/cozie-apple-app-write-influx"
let AWSReadURL = "https://wifmmwu7qe.execute-api.ap-southeast-1.amazonaws.com/development/cozie-apple-app-read-influx"
let AWSWriteAPIKey = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
let AWSReadAPIKey = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"

let OneSignalAppID = "3bca30b5-f5ff-4e3d-b2e7-5a4bc1e96ff7"
