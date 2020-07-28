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

    // improvement get  other physiological parameters, activity, energy burned last hour, steps, body mass, pressure

    @IBOutlet weak var stopButton: WKInterfaceButton!
    @IBOutlet weak var backButton: WKInterfaceButton!
    @IBOutlet var questionTitle: WKInterfaceLabel!
    @IBOutlet var tableView: WKInterfaceTable!

    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")

    var locationManager: CLLocationManager = CLLocationManager()

    var currentQuestion = 0
    var nextQuestion = 0

    // structure which is used to store the questions prompted to the user
    struct Question {
        let title: String
        let options: Array<String>
        let icons: Array<String>
        let nextQuestion: Array<Int>
        let identifier: String
    }

    // array of questions
    var questions = [Question]()

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
    }

    // array of
    var answers = [Answer]()  // it stores the answer after user as completed Cozie
    var tmpResponses: [String: String] = [:]  // it temporally stores user's answers
    var tmpHearthRate: [String: Int] = [:]  // it temporally stores user's answers

    var startTime = ""  // placeholder for the start time of the survey

    var participantID = "undefined" // placeholder for the user ID

    var questionsDisplayed = [0] // this holds in memory which questions was previously shown

    var lat: Double = 0.0
    var long: Double = 0.0
    var locationTimestamp = ""

    var uuid = ""
    var voteLog = 0

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        authorizeHealthKit()

        // save on first startup the UUID in user defaults so it does not change
        // improvement make sure uuid persists between installs
        let userDefaults = UserDefaults.standard
        uuid = userDefaults.string(forKey: "uuid") ?? ""
        if (uuid == "") {
            uuid = UUID().uuidString
            userDefaults.set(uuid, forKey: "uuid")
        }

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

        if let messageReceived = session.receivedApplicationContext as? [String: String] {
            participantID = messageReceived["participantID"] ?? participantID
        }
    }


    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
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
            let _: Void = locationManager.requestLocation()
            startHeartRateQuery(quantityTypeIdentifier: .heartRate)

            // increase the voteLog by one and then store it
            let userDefaults = UserDefaults.standard
            voteLog = userDefaults.integer(forKey: "voteLog")
            voteLog += 1
            userDefaults.set(voteLog, forKey: "voteLog")

        }

        // adding the response to the tmp array of strings
        tmpResponses[questions[currentQuestion].identifier] = questions[currentQuestion].options[rowIndex]

        currentQuestion = nextQuestion

        // check if user completed the survey
        if (currentQuestion == 999) {
            currentQuestion = 0  // reset question flow to start

            // pushController(withName: "ThankYouController", context: questions[currentQuestion].options[rowIndex])

            let endTime = GetDateTimeISOString()

            SendDataDatabase(answer: Answer(startTimestamp: startTime, endTimestamp: endTime, heartRate: tmpHearthRate,
                    participantID: participantID, deviceUUID: uuid,
                    locationTimestamp: locationTimestamp, latitude: lat, longitude: long, responses: tmpResponses, voteLog: voteLog))

            // clear temporary arrays
            tmpResponses.removeAll()
            tmpHearthRate.removeAll()
        }

        // show next question
        loadTableData(question: &questions[currentQuestion], backPressed: false)
    }

    private func defineQuestions() {

        // Last question MUST have nextQuestion set to 999
        questions += [
            Question(title: "How would you prefer to be?", options: ["Cooler", "No Change", "Warmer"],
                    icons: ["cold", "happy", "hot"], nextQuestion: [1, 2, 3], identifier: "tc-preference"),
            Question(title: "Activity last 10-minutes", options: ["Relaxing", "Typing", "Standing", "Exercising"],
                    icons: ["relaxing", "sitting", "standing", "walking"], nextQuestion: [2, 2, 2, 2], identifier: "met"),
            Question(title: "Where are you?", options: ["Home", "Office"], icons: ["house", "office"],
                    nextQuestion: [4, 4], identifier: "location-place"),
            Question(title: "Mood", options: ["Happy", "Sad"], icons: ["house", "office"], nextQuestion: [4, 4],
                    identifier: "mood"),
            Question(title: "Are you?", options: ["Indoor", "Outdoor"], icons: ["house", "outdoor"],
                    nextQuestion: [5, 5], identifier: "location-in-out"),
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

    func authorizeHealthKit() {

        // Used to define the identifiers that create quantity type objects.
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        // Requests permission to save and read the specified data types.
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async() {
            print("data received from the iPhone")
        }
    }

    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {

        // We want data points from our current device
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])

        let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        // It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed.
//        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        let query: HKSampleQuery = HKSampleQuery(sampleType: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
                predicate: devicePredicate, limit: 10, sortDescriptors: [sortByDate]) {
            query, results, error in

            guard let samples = results as? [HKQuantitySample] else {
                // Handle any errors here.
                return
            }

            for sample in samples {

                // date when the HR was sampled
                let sampledDate = FormatDateISOString(date: sample.startDate)
                self.tmpHearthRate[sampledDate] = Int(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))

            }

            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.

            DispatchQueue.main.async {
                // Update the UI here.
            }
        }

        // optimize I am not waiting for this assignment hence it may be that the survey it is sent before these values are updated
        healthStore.execute(query)
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
