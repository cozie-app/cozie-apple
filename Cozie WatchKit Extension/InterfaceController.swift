//
//  InterfaceController.swift
//  Cozie WatchKit Extension
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import HealthKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate, CLLocationManagerDelegate {

    // code related to the watch connectivity with the phone
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    let session = WCSession.default
    let userDefaults = UserDefaults.standard
    let healthStore = HealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    var locationManager: CLLocationManager = CLLocationManager()

    // improvement get  other physiological parameters, activity, energy burned last hour, steps

    @IBOutlet weak var stopButton: WKInterfaceButton!
    @IBOutlet weak var backButton: WKInterfaceButton!
    @IBOutlet var questionTitle: WKInterfaceLabel!
    @IBOutlet var tableView: WKInterfaceTable!

    // structure which is used to store the questions prompted to the user
    struct Question {
        let title: String
        let options: Array<String>
        let icons: Array<String>
        let nextQuestion: Array<Int>
        let identifier: String
    }

    // temp dictionary to store the answers
    struct Answer: Codable {
        let startTimestamp: String
        let endTimestamp: String
        let heartRate: [String: Int]
        let participantID: String
        let deviceUUID: String
        let locationTimestamp: String
        let latitude: Double
        let longitude: Double
        let responses: [String: String]
        let voteLog: Int
        let bodyMass: Double
    }

    // initialize variables
    var questions = [Question]()
    var answers = [Answer]()  // it stores the answer after user as completed Cozie
    var tmpResponses: [String: String] = [:]  // it temporally stores user's answers
    var tmpHearthRate: [String: Int] = [:]  // it temporally stores user's answers
    var bodyMass: Double = 0.0
    var startTime = ""  // placeholder for the start time of the survey
    var participantID = "undefined" // placeholder for the user ID
    var questionsDisplayed = [0] // this holds in memory which questions was previously shown
    var lat: Double = 0.0
    var long: Double = 0.0
    var locationTimestamp = ""
    var uuid = ""
    var voteLog = 0
    var currentQuestion = 0
    var nextQuestion = 0

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // save on first startup the UUID in user defaults so it does not change
        uuid = userDefaults.string(forKey: "uuid") ?? ""
        if (uuid == "") {
            uuid = UUID().uuidString
            userDefaults.set(uuid, forKey: "uuid")
        }

        // get participantID from the defaults if available
        participantID = userDefaults.string(forKey: "participantID") ?? "undefined"

        // start connection session with the phone
        session.delegate = self
        session.activate()

        // append new questions to the questions array
        defineQuestions()

        // changes the text and labels in the table view
        loadTableData(question: &questions[currentQuestion], backPressed: false)

        locationManager.requestWhenInUseAuthorization()
        // change if more accurate location is needed
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
    }

    // this function fires when a message from the phone is received
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        participantID = message["participantID"] as! String

        userDefaults.set(participantID, forKey: "participantID")

        // vibrate the watch to notify the user that it worked
        WKInterfaceDevice.current().play(.notification)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        print("App shown to the user")

        // I am requesting the location when the app is shown in the foreground
        let _: Void = locationManager.requestLocation()

        // improvement some of the following query do not need to be performed everytime willActivate is triggered
        healthStore.authorizeHealthKit { (success, error) in
            if success {
                //get weight
                self.healthStore.bodyMassKg(completion: { (mass, bodyMassDate) in
                    if mass != nil {
//                        print("bodyMass: \(mass)   date: \(bodyMassDate)")
                        self.bodyMass = mass!
                    }
                })
                //get basal energy
                self.healthStore.basalEnergy(completion: { (energy, date) in
                    if energy != nil {
//                        print("basal energy: \(energy)   date: \(date)")
//                        self.bodyMass = energy!
                    }
                })
                //get HR
                self.healthStore.queryHeartRate(completion: { (heartRate) in
                    if heartRate != nil {
//                        print("bodyMass: \(heartRate)")
                        self.tmpHearthRate = heartRate!
                    }
                })
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func loadTableData(question: inout Question, backPressed: Bool) {

        // updates the index of the question to be shown
        if (backPressed == false) {
            questionsDisplayed.append(currentQuestion)
        } else {
            if (questionsDisplayed.count == 1) {
                questionsDisplayed.append(0)
            }
        }

        // hide stop and back buttons if first question is displayed
        if (currentQuestion == 0) {
            backButton.setAlpha(0)
            stopButton.setAlpha(0)
        } else {
            backButton.setAlpha(1)
            stopButton.setAlpha(1)
        }

        // set the title of the question
        questionTitle.setText(question.title)

        // set the number of rows in the table
        tableView.setNumberOfRows(question.options.count, withRowType: "RowController")

        // set the label in each row of the table and the image
        for (index, rowModel) in question.options.enumerated() {

            if let rowController = tableView.rowController(at: index) as? RowController {
                rowController.rowLabel.setText(rowModel)
                rowController.rowImage.setImageNamed(question.icons[index])
            }
        }

    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {

        // find the index of the next question to show
        nextQuestion = questions[currentQuestion].nextQuestion[rowIndex]

        if (currentQuestion == 0) {

            startTime = GetDateTimeISOString()

            // increase the voteLog by one and then store it

        }

        // adding the response to the tmp array of strings
        tmpResponses[questions[currentQuestion].identifier] = questions[currentQuestion].options[rowIndex]

        currentQuestion = nextQuestion

        // check if user completed the survey
        if (currentQuestion == 999) {
            currentQuestion = 0  // reset question flow to start
            
            let userDefaults = UserDefaults.standard
            voteLog = userDefaults.integer(forKey: "voteLog")
            voteLog += 1
            userDefaults.set(voteLog, forKey: "voteLog")

            // pushController(withName: "ThankYouController", context: questions[currentQuestion].options[rowIndex])

            let endTime = GetDateTimeISOString()

            SendDataDatabase(answer: Answer(startTimestamp: startTime, endTimestamp: endTime, heartRate: tmpHearthRate,
                    participantID: participantID, deviceUUID: uuid,
                    locationTimestamp: locationTimestamp, latitude: lat, longitude: long, responses: tmpResponses,
                    voteLog: voteLog, bodyMass: bodyMass))

            // clear temporary arrays
            tmpResponses.removeAll()
            tmpHearthRate.removeAll()
        }

        // show next question
        loadTableData(question: &questions[currentQuestion], backPressed: false)
    }

    private func defineQuestions() {

        // Last question MUST have nextQuestion set to 999, the first question is question 0
        questions += [
            Question(title: "How would you prefer to be?", options: ["Cooler", "No Change", "Warmer"],
                    icons: ["tp-cooler", "comfortable", "tp-warmer"], nextQuestion: [1, 1, 1], identifier: "tc-preference"),
            Question(title: "Where are you?", options: ["Home", "Office", "Vehicle", "Other"], icons: ["loc-home", "loc-office", "loc-vehicle", "loc-other"],
                    nextQuestion: [2, 2, 2, 2], identifier: "location-place"),
            Question(title: "Are you?", options: ["Indoor", "Outdoor"], icons: ["loc-indoor", "loc-outdoor"],
                    nextQuestion: [3, 3], identifier: "location-in-out"),
            Question(title: "What clothes are you wearing?", options: ["Very light", "Light", "Medium", "Heavy"],
                    icons: ["clo-very-light", "clo-light", "clo-medium", "clo-heavy"], nextQuestion: [4, 4, 4, 4],
                    identifier: "clo"),
            Question(title: "Activity last 10-minutes", options: ["Relaxing", "Sitting", "Standing", "Exercising"],
                    icons: ["met-relaxing", "met-sitting", "met-walking", "met-exercising"], nextQuestion: [7, 7, 7, 7],
                    identifier: "met"),
            Question(title: "Can you perceive air movement?", options: ["Yes", "No"],
                    icons: ["yes", "no"], nextQuestion: [7, 7], identifier: "air-speed"),
            Question(title: "Should the light be?", options: ["Dimmer", "No change", "Brighter"],
                    icons: ["light-dim", "light-comf", "light-bright"], nextQuestion: [7, 7, 7], identifier: "light"),
            Question(title: "Any changes in the last 10-min?",
                    options: ["Yes", "No"], icons: ["yes", "no"], nextQuestion: [8, 8], identifier: "any-change"),
            Question(title: "The air is ...", options: ["Stuffy", "Fresh"],
                    icons: ["air-quality-smelly", "air-quality-fresh"], nextQuestion: [10, 10],
                    identifier: "air-quality"),
            Question(title: "Do you feel ... ?", options: ["Sleepy", "Alert"],
                    icons: ["alertness-sleepy", "alertness-alert"], nextQuestion: [11, 11],
                    identifier: "alertness"),
            Question(title: "Is the space?", options: ["Too Quiet", "Comfortable", "Too noisy"],
                    icons: ["noise-quiet", "noise-no-change", "noise-noisy"], nextQuestion: [12, 12, 12, 12],
                    identifier: "noise"),
            Question(title: "Air movement", options: ["Less", "No Changer", "more"],
                    icons: ["air-mov-less", "air-mov-no-change", "air-mov-more"], nextQuestion: [13, 13, 13],
                    identifier: "air-movement"),
            Question(title: "Thank you for completing the survey", options: ["Submit", "Delete"],
                    icons: ["submit", "delete"], nextQuestion: [999, 999], identifier: "end"),
        ]
    }

    private func SendDataDatabase(answer: Answer) {

        // https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method

        var messages = [Answer]()

        // check if answers are stored locally in UserDefaults, the key is answers
        if let data = UserDefaults.standard.value(forKey: "AnswerCozie") as? Data {

            // decode the messages stored in the local memory and convert them back to structures
            let storedMessages = try? PropertyListDecoder().decode(Array<Answer>.self, from: data)

            // add the last completed survey
            messages = storedMessages!
        }

        messages += [answer]

        var indexMessagesToDelete = [Int]()
        // print("Number of messages to be sent \(messages?.count)")
        for (index, message) in messages.enumerated() {

            do {
                let postMessage = try JSONEncoder().encode(message)
                let statusCodeHTTP = PostRequest(message: postMessage)
                if (statusCodeHTTP == 200) {
                    indexMessagesToDelete.append(index)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }

        // delete the messages that have been sent
        for index in indexMessagesToDelete.reversed() {
            messages.remove(at: index)
        }

        // save the messages to local storage so I replace what was previously there
        UserDefaults.standard.set(try? PropertyListEncoder().encode(messages), forKey: "AnswerCozie")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let currentLocation = locations[0]

        // optimize I am not waiting for this assignment hence it may be that the survey it is sent before these values are updated
        locationTimestamp = FormatDateISOString(date: currentLocation.timestamp)
        lat = currentLocation.coordinate.latitude
        long = currentLocation.coordinate.longitude

        print("User location", lat, long)

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            return
        }
        // Notify the user of any errors.
    }

    @IBAction func backButtonAction() {

        // remove the last element of the array since was the last question shows
        questionsDisplayed.removeLast()
        // set current question to previous question shown
        currentQuestion = questionsDisplayed.last!

        // show previous question
        loadTableData(question: &questions[currentQuestion], backPressed: true)

    }

    @IBAction func stopButtonAction() {

        // re-initiate the variables
        currentQuestion = 0
        questionsDisplayed = [0]

        // show previous question
        loadTableData(question: &questions[currentQuestion], backPressed: false)
    }

}
