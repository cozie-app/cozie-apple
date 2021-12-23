//
//  HomePageViewController.swift
//  Cozie
//
//  Created by MAC on 20/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var viewID: UIView!
    @IBOutlet weak var viewNotificationFreq: UIView!
    @IBOutlet weak var viewParticipationDays: UIView!
    @IBOutlet weak var viewParticipationHours: UIView!
    @IBOutlet weak var viewQuestionnairs: UIView!
    
    @IBOutlet weak var labelThermal: UILabel!
    @IBOutlet weak var labelIDRP: UILabel!
    @IBOutlet weak var labelPDP: UILabel!
    @IBOutlet weak var labelMF: UILabel!
    @IBOutlet weak var labelThermalMINI: UILabel!
    @IBOutlet weak var labelIDRPMINI: UILabel!
    @IBOutlet weak var labelPDPMINI: UILabel!
    @IBOutlet weak var labelMFMINI: UILabel!
    
    @IBOutlet weak var lableExperimentId: UILabel!
    @IBOutlet weak var labelParticipantID: UILabel!
    @IBOutlet weak var labelNotificationFreq: UILabel!
    @IBOutlet weak var labelParticipationDays: UILabel!
    @IBOutlet weak var labelParticipationHours: UILabel!
    @IBOutlet weak var viewSurvey: UIView!
    
    var questionFlag:[Bool] = []
    var labelArray:[UILabel] = []
    var daysFlag:[Bool] = []
    var days:String = ""
    var fromTime:String = ""
    var ToTime:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewID.layer.borderColor = UIColor.lightGray.cgColor
        viewID.layer.borderWidth = 1
        
        viewNotificationFreq.layer.borderColor = UIColor.lightGray.cgColor
        viewNotificationFreq.layer.borderWidth = 1
        
        viewParticipationDays.layer.borderColor = UIColor.lightGray.cgColor
        viewParticipationDays.layer.borderWidth = 1
        
        viewParticipationHours.layer.borderColor = UIColor.lightGray.cgColor
        viewParticipationHours.layer.borderWidth = 1
        
        viewQuestionnairs.layer.borderColor = UIColor.lightGray.cgColor
        viewQuestionnairs.layer.borderWidth = 1
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickSurveyView(_:)))
        viewSurvey.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fillUpData()
    }
    
    @objc private func onClickSurveyView(_: UITapGestureRecognizer){
        if let viewController = self.tabBarController {
            NavigationManager.openWeeklySurvey(viewController)
        }
    }
    
    private func fillUpData(){
        
        self.lableExperimentId.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? ""
        self.labelParticipantID.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? ""
        self.labelNotificationFreq.text = "every " + (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.NotificationFrequency.rawValue) as? Date ?? Date()).get24FormateTimeString() + " hrs"
        
        self.questionFlag = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.questions.rawValue) as? [Bool] ?? [false,false,false,false,false,false,false,false]
        self.labelArray = [labelThermal, labelIDRP, labelPDP, labelMF, labelThermalMINI, labelIDRPMINI, labelPDPMINI, labelMFMINI]
        
        var count = 1
        for i in 0...7{
            switch questionFlag[i] {
            case true:
                self.labelArray[i].text = "\(count). " + (self.labelArray[i].text?.components(separatedBy: ".").last ?? "")
                self.labelArray[i].isHidden = false
                count += 1
            case false:
                self.labelArray[i].isHidden = true
            }
        }
        
        self.daysFlag = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ParticipationDays.rawValue) as? [Bool] ?? [true,true,true,true,true,true,true]
        self.days = ""
        
        for i in 0...6{
            switch i {
            case 0:   days += daysFlag[i] ? "Mon, " : ""
            case 1:   days += daysFlag[i] ? "Tue, " : ""
            case 2:   days += daysFlag[i] ? "Wed, " : ""
            case 3:   days += daysFlag[i] ? "Thu, " : ""
            case 4:   days += daysFlag[i] ? "Fri, " : ""
            case 5:   days += daysFlag[i] ? "Sat, " : ""
            case 6:   days += daysFlag[i] ? "Sun, " : ""
            default:
                break
            }
        }
        
        self.labelParticipationDays.text = String(days.dropLast(2))
        
        self.fromTime = (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.FromTime.rawValue) as? Date ?? Date()).get24FormateTimeString() + "hrs"
        self.ToTime = (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ToTime.rawValue) as? Date ?? Date()).get24FormateTimeString() + "hrs"
        self.labelParticipationHours.text = self.fromTime + " - " + self.ToTime
    }
}
