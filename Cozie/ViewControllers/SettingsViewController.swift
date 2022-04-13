//
//  SettingsViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 22/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import WatchConnectivity

private let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!

    var session: WCSession?

    // MARK: - Properties

    var userInfoHeader: UserInfoHeader!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureUI()

        // activate the connectivity session
        self.configWCSession()
    }

    // MARK: - Helper Functions

    private func configureTableView() {

        self.settingsTableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.settingsTableView.setupPadding()
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        self.settingsTableView.tableHeaderView = userInfoHeader
        self.settingsTableView.tableFooterView = UIView()
    }

    private func configureUI() {

        configureTableView()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        //navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.barTintColor = UIColor(red: 55 / 255, green: 120 / 255, blue: 250 / 255, alpha: 1)
        navigationItem.title = "Settings"
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

    }

    private func configWCSession() {
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    // send the Firebase participant uid to the watch so the value will be appended to the POST request
    private func sendParticipantID() {
        session?.activate()
        if self.session?.isReachable == true {
            self.session?.sendMessage(["participantID":UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", "questions": UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.questions.rawValue) as? [Bool] ?? [false,false,false,false,false,false,false,false]], replyHandler: nil) { error in
                print(error.localizedDescription)
                self.showAlert(title: "Sync failed", message: error.localizedDescription)
            }
        } else {
            self.configWCSession()
            self.showAlert(title: "Sync failed", message: "Unable to sync your watch settings, please open the Cozie app in watch and make sure the watch is not locked.")
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
                if let viewController = self.tabBarController {
                    NavigationManager.openTextView(viewController, isParticipantID: true)
                }
            case .experimentID:
                if let viewController = self.tabBarController {
                    NavigationManager.openTextView(viewController, isParticipantID: false)
                }
            }
        case .GeneralSettings:
            guard let buttonClicked = GeneralSettingOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .sendParticipantIDWatch: sendParticipantID()
            }
        case .Communications:
            guard let buttonClicked = CommunicationOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .reminders: print("user asked to disable reminders")
                UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.NotificationEnable.rawValue, value: !(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.NotificationEnable.rawValue) as? Bool ?? true))
                if (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.NotificationEnable.rawValue) as? Bool ?? true) {
                    LocalNotificationManager.shared.clearNotifications()
                } else {
                    LocalNotificationManager.shared.scheduleReminderNotification()
                }
                self.settingsTableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
            }
        case .ExperimentSettings:
            guard let buttonClicked = ExperimentSettingOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .questionFlow:
                if let viewController = self.tabBarController {
                    NavigationManager.openQuestionFlow(viewController)
                }
            case .ReminderFrequency:
                if let viewController = self.tabBarController {
                    NavigationManager.openNotificationFrequency(viewController, for: .NotificationFrequency, view: self)
                }
            case .participationDays:
                if let viewController = self.tabBarController {
                    NavigationManager.openParticipationDays(viewController)
                }
            case .dailyParticipationHours:
                if let viewController = self.tabBarController {
                    NavigationManager.openDailyParticipation(viewController)
                }
            case .downloadData: Utilities.downloadData(self)
            }
        case .About:
            guard let buttonClicked = AboutOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .cozie:
                let url = URL(string: "https://www.cozie-apple.app")!
                let alert = Utilities.alert(url: url, title: "Cozie")
                present(alert, animated: true, completion: nil)
            case .budsLab:
                let url = URL(string: "https://www.budslab.org")!
                let alert = Utilities.alert(url: url, title: "BUDS Lab")
                present(alert, animated: true, completion: nil)
            }
        }

    }

    private func showAlert(title:String, message:String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UITabBarController: TimePickerDelegate {
    func dailyPicker(selected type: NotificationFrequency.TimePickerType, view: UIViewController) {
        NavigationManager.openNotificationFrequency(self, for: type, view: view, isForSubview: true)
    }
}

extension SettingsViewController {
    
    // TODO: change demo data to actual data
    func createCSV(from array:[Dictionary<String, AnyObject>]?) {
        
        var employeeArray:[Dictionary<String, AnyObject>] =  Array()
        for i in 1...10 {
            var dic = Dictionary<String, AnyObject>()
            dic.updateValue(i as AnyObject, forKey: "EmpID")
            dic.updateValue("NameForEmployee id = \(i)" as AnyObject, forKey: "EmpName")
            employeeArray.append(dic)
        }
                
        var csvString = "\("Employee ID"), \("Employee Name")\n\n"
        for dic in employeeArray {
            csvString = csvString.appending("\(String(describing: dic["EmpID"]!)) , \(String(describing: dic["EmpName"]!))\n")
        }
        
        do {
            let path = try FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false).appendingPathComponent(folderName)
            let fileURL = path.appendingPathComponent("data.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
    }
}

extension SettingsViewController: WCSessionDelegate {
//     session is the connection session between the phone and the watch
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let err = error {
            self.showAlert(title: "Connection Error while activation", message: err.localizedDescription)
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let msg = message["isSurveyAdded"] as? Bool, msg == true {
            // TODO: reload graph
            print("reload graph")
        }
        print("receive \(message)")
    }
}
