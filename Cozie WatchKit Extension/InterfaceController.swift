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
    }
    
    // structure which is used to save user's answers
    struct Answer {
        let question: String
        let answer: String
    }
    
    // array of questions
    var questions = [Question]()
    
    // array of answers
    var answers = [Answer]()
    
    // temp array to store the answers and for testing purposes
    var answersArray: [Int] = []

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // append new questions to the questions array
        loadQuestions()
        
        // print the title of the question appearing on screen
        print(questions[currentQuestion].title)
        
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
        
        // set the label in each row of the table
        for (index, rowModel) in question.options.enumerated() {

            if let rowController = tableView.rowController(at: index) as? RowController {
                rowController.rowLabel.setText(rowModel)
                rowController.rowImage.setImageNamed(question.icons[index])
            }
        }

    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        print("pressed button")
        print(questions[currentQuestion].options[rowIndex])

        // testing the answer array
        answersArray.append(rowIndex)


        // increment received number by one
        currentQuestion = nextQuestion
        
        if (currentQuestion == 999){
            currentQuestion = 0
            pushController(withName: "ThankYouController", context: questions[currentQuestion].options[rowIndex])
            PostRequest()
            answersArray.removeAll()
        }
        
        loadTableData(question: &questions[currentQuestion])
    }
    
    private func loadQuestions() {
        
        let q0 = Question(title: "How would you prefer to be?", options: ["Cooler", "No Change", "Warmer"], icons: ["cold", "happy", "hot"], nextQuestion: 1)
        let q1 = Question(title: "q2", options: ["Good", "Bad"], icons: ["green_watch", "blue_watch"], nextQuestion: 3)
        let q2 = Question(title: "q3", options: ["Cold", "Hot"], icons: ["green_watch", "blue_watch"], nextQuestion: 3)
        let q3 = Question(title: "q4", options: ["Cold", "Hot"], icons: ["green_watch", "blue_watch"], nextQuestion: 999)
        
        questions += [q0, q1, q2, q3]
    }

    private func PostRequest() {
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid

        let parameters = ["answers": answersArray, "name": "jack"] as [String : Any]

        //create the url with URL
        let url = URL(string: "http://ec2-52-76-31-138.ap-southeast-1.compute.amazonaws.com:1880/cozie-apple")! //change the url

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

class ThankYouController: WKInterfaceController {
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
