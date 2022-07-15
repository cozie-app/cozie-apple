//
//  HomePageViewController.swift
//  Cozie
//
//  Created by MAC on 20/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var totalQuestionnairesLabel: UILabel!
    @IBOutlet weak var viewID: UIView!
    @IBOutlet weak var viewNotificationFreq: UIView!
    @IBOutlet weak var viewParticipationDays: UIView!
    @IBOutlet weak var viewParticipationHours: UIView!
    @IBOutlet weak var viewQuestionnaires: UIView!

    @IBOutlet weak var labelFlow: UILabel!

    @IBOutlet weak var labelExperimentID: UILabel!
    @IBOutlet weak var labelParticipantID: UILabel!
    @IBOutlet weak var labelNotificationFreq: UILabel!
    @IBOutlet weak var labelParticipationDays: UILabel!
    @IBOutlet weak var labelParticipationHours: UILabel!
    @IBOutlet weak var viewSurvey: UIView!
    @IBOutlet weak var appIconImg: UIImageView!
    @IBOutlet weak var reminder: UIImageView!

    var selectedQuestionFlow: Int = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.selectedQuestionFlow.rawValue) as? Int ?? 0
    var labelArray: [UILabel] = []
    var daysFlag: [Bool] = []
    var days: String = ""
    var fromTime: String = ""
    var ToTime: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // define question flows
        defineQuestionFlows()

        // set defaults
        let experimentID = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? defaultExperimentID
        let participantID = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? defaultParticipantID
        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue, value: experimentID)
        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue, value: participantID)

        appIconImg.image = UIImage(named: "AppIcon")

        viewID.layer.cornerRadius = 5
        viewID.layer.shadowColor = UIColor.lightGray.cgColor
        viewID.layer.shadowOpacity = 0.6
        viewID.layer.shadowOffset = .zero
        viewID.layer.shadowRadius = 5

        viewParticipationDays.layer.cornerRadius = 5
        viewParticipationDays.layer.shadowColor = UIColor.lightGray.cgColor
        viewParticipationDays.layer.shadowOpacity = 0.6
        viewParticipationDays.layer.shadowOffset = .zero
        viewParticipationDays.layer.shadowRadius = 5

        viewNotificationFreq.layer.cornerRadius = 5
        viewNotificationFreq.layer.shadowColor = UIColor.lightGray.cgColor
        viewNotificationFreq.layer.shadowOpacity = 0.6
        viewNotificationFreq.layer.shadowOffset = .zero
        viewNotificationFreq.layer.shadowRadius = 5

        viewParticipationHours.layer.cornerRadius = 5
        viewParticipationHours.layer.shadowColor = UIColor.lightGray.cgColor
        viewParticipationHours.layer.shadowOpacity = 0.6
        viewParticipationHours.layer.shadowOffset = .zero
        viewParticipationHours.layer.shadowRadius = 5

        viewQuestionnaires.layer.cornerRadius = 5
        viewQuestionnaires.layer.shadowColor = UIColor.lightGray.cgColor
        viewQuestionnaires.layer.shadowOpacity = 0.6
        viewQuestionnaires.layer.shadowOffset = .zero
        viewQuestionnaires.layer.shadowRadius = 5

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        self.reminder.addGestureRecognizer(imageTap)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClickSurveyView(_:)))
        self.viewSurvey.addGestureRecognizer(tap)

        HealthKitSetupAssistant.authorizeHealthKit { (_, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.setUpBackgroundDeliveryForDataTypes()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utilities.getData { (isSuccess, data) in
            if isSuccess {
                self.reloadPage(forData: data)
            }
        }
        self.fillUpData()
    }

    @objc private func imageTapped(_: UITapGestureRecognizer) {
        if let viewController = self.tabBarController {
            NavigationManager.openReminder(viewController)
        }
    }

    @objc private func onClickSurveyView(_: UITapGestureRecognizer) {
        if let viewController = self.tabBarController {
            NavigationManager.openWeeklySurvey(viewController)
        }
    }

    private func fillUpData() {

        let experimentID = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String
        let participantID = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String

        self.totalQuestionnairesLabel.text = "\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.totalValidResponse.rawValue) as? Int ?? 0)"
        self.labelExperimentID.text = experimentID
        self.labelParticipantID.text = participantID

        self.labelNotificationFreq.text = "Every " + (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ReminderFrequency.rawValue) as? Date ?? defaultNotificationFrq).getHour() + " hours " + (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ReminderFrequency.rawValue) as? Date ?? defaultNotificationFrq).getMinutes() + " minutes"

        self.labelFlow.text = questionFlows[UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.selectedQuestionFlow.rawValue) as? Int ?? 0].title

        self.daysFlag = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ParticipationDays.rawValue) as? [Bool] ?? [true, true, true, true, true, false, false]
        self.days = ""

        for i in 0...6 {
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

        self.fromTime = (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.FromTime.rawValue) as? Date ?? defaultFromTime).get24FormatTimeString() + "hrs"
        self.ToTime = (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ToTime.rawValue) as? Date ?? defaultToTime).get24FormatTimeString() + "hrs"
        self.labelParticipationHours.text = self.fromTime + " - " + self.ToTime
    }
}

extension HomePageViewController {
    func reloadPage(forData: [Response]) {
        let actualResponse = forData.filter {
            $0.vote_count != nil
        }
        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.totalValidResponse.rawValue, value: actualResponse.count)
        self.totalQuestionnairesLabel.text = "\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.totalValidResponse.rawValue) as? Int ?? 0)"
    }
}
