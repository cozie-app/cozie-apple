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

struct QuestionResponse: Codable {
    var Thermal: [Question]
    var Privacy: [Question]
    var Movement: [Question]
    var InfectionRisk: [Question]
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

    // initialize variables
    var questions = [Question]()
    var answers = [Answer]()  // it stores the answer after user as completed Cozie
    var tmpResponses: [String: String] = [:]  // it temporally stores user's answers
    var tmpHearthRate: [String: Int] = [:]  // it temporally stores user's answers
    var bodyMass: Double = 0.0
    var audioExposure: Double = 0.0
    var startTime = ""  // placeholder for the start time of the survey
    var participantID = "ExternalTester" // placeholder for the user ID
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

        defineQuestionFlows()

        // save on first startup the UUID in user defaults so it does not change
        uuid = userDefaults.string(forKey: "uuid") ?? "undefined"
        // get participantID from the defaults if available
        participantID = userDefaults.string(forKey: "participantID") ?? participantID

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
    
    func sendMessageToPhone(message: [String:Any]) {
        session.sendMessage(message) { message in
            print("sent[\(message.values)]")
        } errorHandler: { err in
            print("error: \(err)")
        }
    }

    // this function fires when a message from the phone is received
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let id = message["participantID"] as? String {
            participantID = id
            userDefaults.set(id, forKey: "participantID")
        }
        if let question = message["questions"] as? Int {
            userDefaults.set(question, forKey: "questions")
            defineQuestions()
        }
        WKInterfaceDevice.current().play(.notification)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let question = message["questions"] as? Int {
            userDefaults.set(question, forKey: "questions")
            defineQuestions()
        }
        if let id = message["participantID"] as? String {
            participantID = id
            userDefaults.set(id, forKey: "participantID")
        }
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
                self.healthStore.noiseExposure(completion: { (noise, noiseDate) in
                    if noise != nil {
                        self.audioExposure = noise!
                    }
                })

                print("audio \(self.audioExposure)")

                //get weight
                self.healthStore.bodyMassKg(completion: { (mass, bodyMassDate) in
                    if mass != nil {
                        self.bodyMass = mass!
                    }
                })

                print(self.bodyMass)

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
                        self.tmpHearthRate = heartRate!
                    }
                })

                print(self.tmpHearthRate)
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
        
        // scroll back the view to the top of the page
        scroll(to: questionTitle, at: .top, animated: true)
        
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

            if (uuid == "undefined") {
                uuid = UUID().uuidString
                userDefaults.set(uuid, forKey: "uuid")
            }

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

            var qa: [QuestionAnswer] = []
            tmpResponses.forEach { (question, answer) in
                qa.append(QuestionAnswer(voteLog: voteLog, question: question, answer: answer))
            }
            CoreDataManager.shared.createSurvey(surveys: [SurveyDetails(voteLog: voteLog, locationTimestamp: locationTimestamp, startTimestamp: startTime, endTimestamp: endTime, participantID: participantID, deviceUUID: uuid, latitude: lat, longitude: long, bodyMass: bodyMass, responses: qa, heartRate: 1, isSync: false)])
            SendDataDatabase(answer: Answer(startTimestamp: startTime, endTimestamp: endTime, heartRate: tmpHearthRate,
                    participantID: participantID, deviceUUID: uuid,
                    locationTimestamp: locationTimestamp, latitude: lat, longitude: long, responses: tmpResponses,
                    voteLog: voteLog, bodyMass: bodyMass))
            self.sendMessageToPhone(message: ["isSurveyAdded":true])
            // clear temporary arrays
            tmpResponses.removeAll()
            tmpHearthRate.removeAll()
        }

        // show next question
        loadTableData(question: &questions[currentQuestion], backPressed: false)
    }

    private func defineQuestions() {
        self.questions.removeAll()
        
        print(userDefaults.object(forKey: "questions") as? Int ?? 0)

        self.questions = questionFlows[userDefaults.object(forKey: "questions") as? Int ?? 0].questions

        self.questions += [Question(title: "Thank you.", identifier: "end", options: ["Submit survey"],
                icons: ["submit"], nextQuestion: [999])]
        loadTableData(question: &questions[0], backPressed: false)
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
                print("error IC: \(error.localizedDescription)")
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
