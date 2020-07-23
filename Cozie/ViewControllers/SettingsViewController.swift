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

    // session is the connection session between the phone and the watch
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    var session: WCSession?

    // MARK: - Properties

    var tableView: UITableView!
    var userInfoHeader: UserInfoHeader!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureUI()
    }

    // MARK: - Helper Functions

    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.sectionHeaderHeight = 40

        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame

        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        tableView.tableHeaderView = userInfoHeader
        tableView.tableFooterView = UIView()
    }

    func configureUI() {
        configureTableView()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.barTintColor = UIColor(red: 55 / 255, green: 120 / 255, blue: 250 / 255, alpha: 1)
        navigationItem.title = "Settings"
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
    }

    func signOut() {
        do {
            try Auth.auth().signOut()

            let startViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.startViewController)

            view.window?.rootViewController = startViewController
            view.window?.makeKeyAndVisible()

        } catch let error {
            print("Failed to sign out with error", error)
        }

    }

    func sendParticipantID() {

        // check if watch connectivity is supported and activate it
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()

            do {
                try session?.updateApplicationContext(["participantID": participantID])
                print("Sent user ID")
            } catch {
                let alertController = UIAlertController(title: nil, message: "Something went wrong. Please ensure that the phone and the watch are both on and connected then press the button again.",
                        preferredStyle: .actionSheet)

                alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

                present(alertController, animated: true, completion: nil)
            }
        }
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let section = SettingsSections(rawValue: section) else {
            return 0
        }

        switch section {
        case .Settings: return SocialOptions.allCases.count
        case .Communications: return CommunicationOptions.allCases.count
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

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell

        guard let section = SettingsSections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {
        case .Settings:
            let social = SocialOptions(rawValue: indexPath.row)
            cell.sectionType = social
        case .Communications:
            let communication = CommunicationOptions(rawValue: indexPath.row)
            cell.sectionType = communication
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let section = SettingsSections(rawValue: indexPath.section) else {
            return
        }

        switch section {
        case .Settings:
            guard let buttonClicked = SocialOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
            case .logout: logOutPressed()
            case .sendParticipantIDWatch: sendParticipantID()
            }
        case .Communications:
            guard let buttonClicked = CommunicationOptions(rawValue: indexPath.row) else {
                return
            }
            switch buttonClicked {
                    // fixme hide this button if the user has not yet completed consent form
            case .emailConsent: sendConsentForm()
                    // fixme when the button below is clicked it throws an error
            case .notification: print("user asked to disable notifications")
            }
        }

    }

    func logOutPressed() {

        let alertController = UIAlertController(title: nil, message: "Are you sure you want to Log Out?",
                preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive,
                handler: { (alert: UIAlertAction!) in self.signOut() }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)

    }

    func sendConsentForm() {

        let taskViewController = ORKTaskViewController(task: consentPDFViewerTask(), taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)

    }

}
