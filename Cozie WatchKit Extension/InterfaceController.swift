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


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    // todo get physiological parameters
    // todo add user ID
    // todo add login screen https://www.youtube.com/watch?v=1HN7usMROt8

    @IBOutlet weak var stopButton: WKInterfaceButton!
    @IBOutlet weak var backButton: WKInterfaceButton!
    @IBOutlet var questionTitle: WKInterfaceLabel!
    @IBOutlet var tableView: WKInterfaceTable!

    var locationManager: CLLocationManager = CLLocationManager()

    var currentQuestion = 0
    var nextQuestion = 0
    var previousQuestion = 0

    // structure which is used for the questions
    struct QuestionCozie {
        let title: String
        let options: Array<String>
        let icons: Array<String>
        let nextQuestion: Int
        let identifier: String
    }

    // array of questions
    var questions = [QuestionCozie]()

    // temp dictionary to store the answers and for testing purposes
    struct AnswerCozie: Codable {
        let startTimestamp: String
        let endTimestamp: String
        let heartRate: Int
        let bodyPresence: Bool
        let participantID: String
        let locationTimestamp: String
        let latitude: Double
        let longitude: Double
        let responses: [String: String]
    }

    var answers = [AnswerCozie]()  // it stores the answer after user as completed Cozie
    // todo delete variable below since it is not needed and in the loop update automatically answers.responses
    var tmpAnswers: [String: String] = [:]  // it temporally stores user's answers

    var startTime = ""  // placeholder for the start time of the survey

    var lat: Double = 0.0
    var long: Double = 0.0
    var locationTimestamp = ""

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // append new questions to the questions array
        defineQuestions()

        // changes the text and labels in the table view
        loadTableData(question: &questions[currentQuestion])

        locationManager.requestWhenInUseAuthorization()
        // change if more accurate location is needed
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
    }


    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    private func loadTableData(question: inout QuestionCozie) {

        // set the title of the question
        questionTitle.setText(question.title)

        // set the number of rows in the table
        tableView.setNumberOfRows(question.options.count, withRowType: "RowController")

        // find the index of the next question to show
        nextQuestion = question.nextQuestion

        // set the label in each row of the table and the image
        for (index, rowModel) in question.options.enumerated() {

            if let rowController = tableView.rowController(at: index) as? RowController {
                rowController.rowLabel.setText(rowModel)
                rowController.rowImage.setImageNamed(question.icons[index])
            }
        }

    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {

        if (currentQuestion == 0) {
            startTime = GetDateTimeISOString()
            let _: Void = locationManager.requestLocation()
        }

        // adding the response to the tmp array of strings
        tmpAnswers[questions[currentQuestion].identifier] = questions[currentQuestion].options[rowIndex]

        // updates the index of the question to be shown
        previousQuestion = currentQuestion
        currentQuestion = nextQuestion

        // check if user completed the survey
        if (currentQuestion == 999) {
            currentQuestion = 0  // reset question flow to start

            // pushController(withName: "ThankYouController", context: questions[currentQuestion].options[rowIndex])

            let endTime = GetDateTimeISOString()

            // todo change the constant values below with data from Apple APIs
            SendDataDatabase(answer: AnswerCozie(startTimestamp: startTime, endTimestamp: endTime, heartRate: 80, bodyPresence: true,
                    participantID: "test999", locationTimestamp: locationTimestamp, latitude: lat, longitude: long,
                    responses: tmpAnswers))

            tmpAnswers.removeAll()
        }

        // show next question
        loadTableData(question: &questions[currentQuestion])
    }

    private func defineQuestions() {

        // Last question MUST have nextQuestion set to 999

        questions += [
            QuestionCozie(title: "How would you prefer to be?", options: ["Cooler", "No Change", "Warmer"],
                    icons: ["cold", "happy", "hot"], nextQuestion: 1, identifier: "tc-preference"),
            QuestionCozie(title: "Activity last 10-minutes", options: ["Relaxing", "Typing", "Standing", "Exercising"],
                    icons: ["relaxing", "sitting", "standing", "walking"], nextQuestion: 2, identifier: "met"),
            QuestionCozie(title: "Where are you?", options: ["Home", "Office"], icons: ["house", "office"],
                    nextQuestion: 4, identifier: "location-place"),
            QuestionCozie(title: "Mood", options: ["Happy", "Sad"], icons: ["house", "office"], nextQuestion: 4,
                    identifier: "mood"),
            QuestionCozie(title: "Are you?", options: ["Indoor", "Outdoor"], icons: ["house", "outdoor"],
                    nextQuestion: 5, identifier: "location-in-out"),
            QuestionCozie(title: "Thank you for completing the survey", options: ["Submit", "Delete"],
                    icons: ["submit", "delete"], nextQuestion: 999, identifier: "end"),
        ]
    }

    private func SendDataDatabase(answer: AnswerCozie) {

        // https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method

        var messages = [AnswerCozie]()

        // check if answers are stored locally in UserDefaults, the key is answers
        if let data = UserDefaults.standard.value(forKey: "AnswerCozie") as? Data {

            // decode the messages stored in the local memory and convert them back to structures
            let storedMessages = try? PropertyListDecoder().decode(Array<AnswerCozie>.self, from: data)

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

        // todo I am not waiting for this assignment hence it may be that the survey it is sent before these values are updated
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        locationTimestamp = formatter.string(from: currentLocation.timestamp)
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
        // todo the back button is working but only goes back by one question

        currentQuestion = previousQuestion

        // show previous question
        loadTableData(question: &questions[currentQuestion])
    }

    @IBAction func stopButtonAction() {
        currentQuestion = 0

        // show previous question
        loadTableData(question: &questions[currentQuestion])
    }

}
