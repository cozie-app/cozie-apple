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

let primaryColour = UIColor(named: "primaryColour")

let imgGithub = "githubLogo"
let imgBudsLab = "budsLabIcon"
let imgDownload = "downloadData"
