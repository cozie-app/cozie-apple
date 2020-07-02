//
//  InterfaceController.swift
//  Cozie WatchKit Extension
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    // todo allow the user to go back to previous question and close the survey if need be
    // todo get user's location
    // todo get physiological parameters
    // todo implement notifications
    // todo save current survey responses if POST request was not successful

    @IBOutlet var questionTitle: WKInterfaceLabel!
    @IBOutlet var tableView: WKInterfaceTable!
    
    var currentQuestion = 0
    var nextQuestion = 0
    
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
    
    // temp array to store the answers and for testing purposes
    var answers: [String: String] = [:]

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // append new questions to the questions array
        loadQuestions()
        
        // changes the text and labels in the table view
        loadTableData(question: &questions[currentQuestion])
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

        // adding the response to the dictionary
        answers[questions[currentQuestion].identifier] = questions[currentQuestion].options[rowIndex]

        // increment received number by one
        currentQuestion = nextQuestion
        
        if (currentQuestion == 999){
            currentQuestion = 0
//            pushController(withName: "ThankYouController", context: questions[currentQuestion].options[rowIndex])
            PostRequest()
        }
        
        loadTableData(question: &questions[currentQuestion])
    }
    
    private func loadQuestions() {
        
        let q0 = Question(title: "How would you prefer to be?", options: ["Cooler", "No Change", "Warmer"], icons: ["cold", "happy", "hot"], nextQuestion: 1, identifier: "tc-preference")
        let q1 = Question(title: "Activity last 10-minutes", options: ["Relaxing", "Typing", "Standing", "Exercising"], icons: ["relaxing", "sitting", "standing", "walking"], nextQuestion: 2, identifier: "met")
        let q2 = Question(title: "Where are you?", options: ["Home", "Office"], icons: ["house", "office"], nextQuestion: 4, identifier: "location-place")
        let q3 = Question(title: "Mood", options: ["Happy", "Sad"], icons: ["house", "office"], nextQuestion: 4, identifier: "mood")
        let q4 = Question(title: "Are you?", options: ["Indoor", "Outdoor"], icons: ["house", "outdoor"], nextQuestion: 5, identifier: "location-in-out")
        let q5 = Question(title: "Thank you for completing the survey", options: ["Submit", "Delete"], icons: ["submit", "delete"], nextQuestion: 999, identifier: "end")

        questions += [q0, q1, q2, q3, q4, q5]
    }

    private func PostRequest() {
        // https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method

        let parameters = ["answers": answers, "timestamp": NSDate().timeIntervalSince1970] as [String : Any]

        //create the url with URL
        let url = URL(string: "https://qepkde7ul7.execute-api.us-east-1.amazonaws.com/default/CozieApple-to-influx")! //change the url

        //create the session object
        let session = URLSession.shared

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.setValue("3lvUimwWTv3UlSjSct0RS3yxQWIKFG0G7bcWtM10", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            // todo fix the code below since it is not parsing the JSON and not checking for response number
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }

}
