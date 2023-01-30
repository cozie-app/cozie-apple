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
//let defaultExperimentID = "AppleStore"
let defaultExperimentID = "alda"

// Generate randomized default participant id
let suffix_letters = "ABCDEFGHKLMNPQRSTUVWXYZ23456789" //IJO01 are intentionally missing
let suffix_length = 8
let suffix = String((0..<suffix_length).map{ _ in suffix_letters.randomElement()! })
//let defaultParticipantID = "Participant_" + suffix
let defaultParticipantID = "alda"

let primaryColour = UIColor(named: "primaryColour")

let imgGithub = "githubLogo"
//let imgBudsLab = "budsLabIcon"
let imgDownload = "downloadData"
let folderName = "Cozie"

let AWSWriteURL = "https://wifmmwu7qe.execute-api.ap-southeast-1.amazonaws.com/development/cozie-apple-app-write-influx"
let AWSReadURL = "https://wifmmwu7qe.execute-api.ap-southeast-1.amazonaws.com/development/cozie-apple-app-read-influx"
let AWSWriteAPIKey = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
let AWSReadAPIKey = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"

let OneSignalAppID = "d0cdbdda-8e22-4958-99d0-a7b378d2f8bd"
