//
//  Defaults.swift
//  Cozie
//
//  Created by Mario Frei on 25/8/23.
//

import Foundation


struct Defaults {
    static let experimentID = "AppStore"
    //static let experimentID = "dev"

    static func generateParticipantID() -> String {
        // Generate randomized default participant id
        let suffix_letters = "ABCDEFGHKLMNPQRSTUVWXYZ23456789" //IJO01 are intentionally missing
        let suffix_length = 8
        let suffix = String((0..<suffix_length).map{ _ in suffix_letters.randomElement()! })
        let participantID = "Participant_" + suffix
        //let participantID = "simulator"
        return participantID
    }
    static func generatePasswordID() -> String {
        let password_letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890*&%$#@"
        let password_length = 16
        let password = String((0..<password_length).map{ _ in password_letters.randomElement()! })
        return password
    }
    static let WSStitle = "Weather (short)"
    static let WSSgoal: Int16 = 100
    static let WSStimeOutTime: Int16 = 55
    static let WSSreminderEnabled = true
    static let WSSreminderInterval: Int16 = 60
    static let WSSparticipationDays: String = "Mo,Tu,We,Th,Fr"
    static let WSSparticiaptionTimeStart = "09:00"
    static let WSSparticipationTimeEnd = "18:00"
    static let PSSreminderEnabled = false
    static let PSSreminderTime = ""
    static let PSSreminderDays  = ""
    
    static let APIwriteURL: String = "https://43cb5nnwe3mejojyftbuaow4640nsrnd.lambda-url.ap-southeast-1.on.aws"
    static let APIwriteKey: String = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
    static let APIreadURL: String = "https://at6x6b7v54hmoki6dlyew72csq0ihxrn.lambda-url.ap-southeast-1.on.aws"
    static let APIreadKey: String = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
    static let OneSignalAppID: String = "be00093b-ed75-4c2e-81af-d6b382587283"
    static let watchSurveyLink: String = "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_weather_short.txt"
    
    // The values below need to replace the values stored in AppLinks.swift
    static let phoneSurveyLink: String = "https://docs.google.com/forms/d/e/1FAIpQLSchX6cIqgx7tupV_47o5sYVs5IvEBqhwTMGuRLCjGxqbh_gTA/viewform?usp=pp_url&entry.247006640=dev&entry.932499052=dev01"
    static let cozieWebsiteURL: String = "https://www.cozie-apple.app"
    static let cozieGithubURL: String = "https://github.com/cozie-app/cozie-apple"
    
    static let locationChangeDistanceThreshold: Double = 10

}
