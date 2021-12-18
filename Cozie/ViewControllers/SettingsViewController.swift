//
//  SettingsViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 22/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import WatchConnectivity
import ResearchKit
import FirebaseAuth

private let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController, WCSessionDelegate, ORKTaskViewControllerDelegate {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    // session is the connection session between the phone and the watch
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    var session: WCSession?

    // MARK: - Properties

    var userInfoHeader: UserInfoHeader!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureUI()

        // activate the connectivity session
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    // MARK: - Helper Functions

    private func configureTableView() {

        self.settingsTableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        if #available(iOS 15.0, *) {
            self.settingsTableView.sectionHeaderTopPadding = 0
        }
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        self.settingsTableView.tableHeaderView = userInfoHeader
        self.settingsTableView.tableFooterView = UIView()
    }

    private func configureUI() {

        configureTableView()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.barTintColor = UIColor(red: 55 / 255, green: 120 / 255, blue: 250 / 255, alpha: 1)
        navigationItem.title = "Settings"

    }

    func taskViewController(_ taskViewController: ORKTaskViewController,
                            didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
    }

    private func signOut() {

        do {
            try Auth.auth().signOut()

            let startViewController = storyboard?.instantiateViewController(identifier: ViewControllersNames.Storyboard.startViewController)

            view.window?.rootViewController = startViewController
            view.window?.makeKeyAndVisible()

        } catch let error {
            print("Failed to sign out with error", error)
        }

    }

    // send the Firebase participant uid to the watch so the value will be appended to the POST request
    private func sendParticipantID() {
        
        // check if watch connectivity is supported and activate it
        if WCSession.isSupported() {
            
            // send participant id to watch
            // improvement show popup if message failed
            session?.sendMessage(["participantID": userFirebaseUID], replyHandler: nil, errorHandler: {err in print("did not send participant id")}
            )
        }
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    // programmatically populate and format settings table
    public func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let section = SettingsSections(rawValue: section) else {
            return 0
        }

        switch section {
        case .GeneralSettings: return GeneralSettingOptions.allCases.count
        case .Communications: return CommunicationOptions.allCases.count - (false ? 1 : 0) // TODO: hide sendConsentForm button if the user has not yet completed consent form
        case .UserSettings: return UserSettingOptions.allCases.count
        case .ExperimentSettings: return ExperimentSettingOptions.allCases.count
        case .OnboardingProcess: return OnboardingProcessOptions.allCases.count
        case .About: return AboutOptions.allCases.count
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground

        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
//        title.textColor = .white
        title.text = SettingsSections(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true

        return view

    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
//
//    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return .leastNormalMagnitude
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        cell.selectionStyle = .none
        guard let section = SettingsSections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {
        case .GeneralSettings:
            let social = GeneralSettingOptions(rawValue: indexPath.row)
            cell.sectionType = social
        case .Communications:
            let communication = CommunicationOptions(rawValue: indexPath.row)
            cell.sectionType = communication
        case .UserSettings:
            let userSettings = UserSettingOptions(rawValue: indexPath.row)
            cell.sectionType = userSettings
        case .ExperimentSettings:
            let experimentSettings = ExperimentSettingOptions(rawValue: indexPath.row)
            cell.sectionType = experimentSettings
        case .OnboardingProcess:
            let onboarding = OnboardingProcessOptions(rawValue: indexPath.row)
            cell.sectionType = onboarding
        case .About:
            let about = AboutOptions(rawValue: indexPath.row)
            cell.sectionType = about
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let section = SettingsSections(rawValue: indexPath.section) else {
            return
        }

        switch section {
        case .UserSettings:
            guard let buttonClicked = UserSettingOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .participantID:
                NavigationManager.openTextView(self, isParticipantID: true)
            case .experimentID:
                NavigationManager.openTextView(self, isParticipantID: false)
            }
        case .GeneralSettings:
            guard let buttonClicked = GeneralSettingOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .permissions:
                NavigationManager.openPermissions(self)
            case .sendParticipantIDWatch: sendParticipantID()
            }
        case .Communications:
            guard let buttonClicked = CommunicationOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .notification: print("user asked to disable notifications")
                UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.NotificationEnable.rawValue, value: !(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.NotificationEnable.rawValue) as? Bool ?? true))
                self.settingsTableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
                // fixme hide this button if the user has not yet completed consent form
            case .emailConsent: sendConsentForm()
            }
        case .ExperimentSettings:
            guard let buttonClicked = ExperimentSettingOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .questionFlow:
                NavigationManager.openQuestionFlow(self)
            case .notificationFrequency:
                NavigationManager.openNotificationFrequency(self, for: .NotificationFrequency)
            case .participationDays:
                NavigationManager.openParticipationDays(self)
            case .dailyParticipationHours:
                NavigationManager.openDailyParticipation(self)
            case .downloadData: print("downloadData clicked")
            }
        case .OnboardingProcess:
            guard let buttonClicked = OnboardingProcessOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .eligibility: print("eligibility clicked")
            case .consent: print("consent clicked")
            case .survey: print("survey clicked")
            case .onboarding: print("onboarding clicked")
            }
        case .About:
            guard let buttonClicked = AboutOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .cozie: print("cozie clicked")
            case .budsLab: print("budsLab clicked")
            }
        }

    }

    private func logOutPressed() {

        let alertController = UIAlertController(title: nil, message: "Are you sure you want to Log Out?",
                preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive,
                handler: { (alert: UIAlertAction!) in self.signOut() }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)

    }

    private func sendConsentForm() {

        let taskViewController = ORKTaskViewController(task: consentPDFViewerTask(), taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)

    }

}

extension SettingsViewController: TimePickerDelegate {
    func dailyPicker(selected type: NotificationFrequency.TimePickerType) {
        NavigationManager.openNotificationFrequency(self, for: type)
    }
}
