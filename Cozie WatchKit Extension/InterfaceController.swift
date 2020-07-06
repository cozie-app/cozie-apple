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

    @IBOutlet weak var stopButton: WKInterfaceButton!
    @IBOutlet weak var backButton: WKInterfaceButton!
    @IBOutlet var questionTitle: WKInterfaceLabel!
    @IBOutlet var tableView: WKInterfaceTable!
    
    var locationManager: CLLocationManager = CLLocationManager()

    var currentQuestion = 0
    var nextQuestion = 0
    var previousQuestion = 0

    // structure which is used for the questions
    struct Question {
        let title: String
        let options: Array<String>
        let icons: Array<String>
        let nextQuestion: Int
        let identifier: String
    }

    // array of questions
    var questions = [Question]()

    // temp dictionary to store the answers and for testing purposes
    struct Answer: Codable {
        let startTime: String
        let endTime: String
        let heartRate: Int
        let bodyPresence: Bool
        let participantID: String
        let latitude: Double
        let longitude: Double
        let responses: [String: String]
    }

    var answers = [Answer]()  // it stores the answer after user as completed Cozie
    var tmpAnswers: [String: String] = [:]  // it temporally stores user's answers

    var startTime = ""  // placeholder for the start time of the survey
    
    var lat: Double = 0.0
    var long: Double = 0.0

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

    private func loadTableData(question: inout Question) {

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
        
        if (currentQuestion == 0){
            startTime = GetDateTimeISOString()
            let currentLocation: Void = locationManager.requestLocation()
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
            SendDataDatabase(answer: Answer(startTime: startTime, endTime: endTime, heartRate: 80, bodyPresence: true,
                    participantID: "test999", latitude: lat, longitude: long, responses: tmpAnswers))

            tmpAnswers.removeAll()
        }

        // show next question
        loadTableData(question: &questions[currentQuestion])
    }

    private func defineQuestions() {

        // Last question MUST have nextQuestion set to 999

        questions += [
            Question(title: "How would you prefer to be?", options: ["Cooler", "No Change", "Warmer"], 
                    icons: ["cold", "happy", "hot"], nextQuestion: 1, identifier: "tc-preference"),
            Question(title: "Activity last 10-minutes", options: ["Relaxing", "Typing", "Standing", "Exercising"],
                    icons: ["relaxing", "sitting", "standing", "walking"], nextQuestion: 2, identifier: "met"),
            Question(title: "Where are you?", options: ["Home", "Office"], icons: ["house", "office"],
                    nextQuestion: 4, identifier: "location-place"),
            Question(title: "Mood", options: ["Happy", "Sad"], icons: ["house", "office"], nextQuestion: 4, 
                    identifier: "mood"),
            Question(title: "Are you?", options: ["Indoor", "Outdoor"], icons: ["house", "outdoor"],
                    nextQuestion: 5, identifier: "location-in-out"),
            Question(title: "Thank you for completing the survey", options: ["Submit", "Delete"],
                    icons: ["submit", "delete"], nextQuestion: 999, identifier: "end"),
        ]
    }

    private func SendDataDatabase(answer: Answer) {

        // https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method

        // check if answers are stored locally in UserDefaults, the key is answers
        if let data = UserDefaults.standard.value(forKey:"answers") as? Data {

            // decode the messages stored in the local memory and convert them back to structures
            var messages = try? PropertyListDecoder().decode(Array<Answer>.self, from: data)

            // add the last completed survey
            messages! += [answer]

            var indexMessagesToDelete = [Int]()
            // print("Number of messages to be sent \(messages?.count)")
            for (var index, message) in messages!.enumerated() {
                let statusCodeHTTP = PostRequest(message: message)
                if (statusCodeHTTP == 200){
                    indexMessagesToDelete.append(index)
                }
            }

            // delete the messages that have been sent
            for index in indexMessagesToDelete.reversed() {
                messages?.remove(at: index)
            }

            // save the messages to local storage so I replace what was previously there
            UserDefaults.standard.set(try? PropertyListEncoder().encode(messages), forKey:"answers")

        }
    }

    private func PostRequest(message: Answer) -> Int {
        // create the url with URL
//        let url = URL(string: "https://qepkde7ul7.execute-api.us-east-1.amazonaws.com/default/CozieApple-to-influx")! //change the url
        let url = URL(string: "http://ec2-52-76-31-138.ap-southeast-1.compute.amazonaws.com:1880/cozie-apple")! //change the url

        // create the session object
        let session = URLSession.shared

        // now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST

        do {
            request.httpBody = try JSONEncoder().encode(message)
        } catch let error {
            print(error.localizedDescription)
        }

//        request.setValue("3lvUimwWTv3UlSjSct0RS3yxQWIKFG0G7bcWtM10", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")


        var responseStatusCode = 0
        // semaphore to wait for the function to complete
        let sem = DispatchSemaphore.init(value: 0)

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            defer { sem.signal() }

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            if let response = response {
                let nsHTTPResponse = response as! HTTPURLResponse
                let statusCode = nsHTTPResponse.statusCode
                responseStatusCode = statusCode
            }

            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    // print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })

        // run the async POST request
        task.resume()
        
        // todo maybe write not blocking code or show a message or loader to inform user
        // https://github.com/hirokimu/EMTLoadingIndicator
        sem.wait()
        return responseStatusCode
    }

    private func GetDateTimeISOString() -> String {
        let date = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter.string(from: date)
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
            
        let currentLocation = locations[0]
        
        // todo I am not waiting for this assignment hence it may be that the survey it is sent before these values are updated
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
    
    @IBAction func backButtonAction(){
        // todo the back button is working but only goes back by one question

        currentQuestion = previousQuestion

        // show previous question
        loadTableData(question: &questions[currentQuestion])
    }

    @IBAction func stopButtonAction(){
        currentQuestion = 0

        print(tmpAnswers)
        tmpAnswers.removeAll()
        print(tmpAnswers)

        // show previous question
        loadTableData(question: &questions[currentQuestion])
    }

}
