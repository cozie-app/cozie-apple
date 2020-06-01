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
    
    // array of questions
    var questions = [Question]()
    
    
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
        
        // set the nunmber of rows in the table
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

        // increment received number by one
        currentQuestion = nextQuestion
        
        if (currentQuestion == 999){
            currentQuestion = 0
            pushController(withName: "ThankYouController", context: questions[currentQuestion].options[rowIndex])
        }
        
        loadTableData(question: &questions[currentQuestion])
    }
    
    private func loadQuestions() {
        
        let q0 = Question(title: "q1", options: ["Fine", "Happy"], icons: ["green_watch", "blue_watch"], nextQuestion: 1)
        let q1 = Question(title: "q2", options: ["Good", "Bad"], icons: ["green_watch", "blue_watch"], nextQuestion: 3)
        let q2 = Question(title: "q3", options: ["Cold", "Hot"], icons: ["green_watch", "blue_watch"], nextQuestion: 3)
        let q3 = Question(title: "q4", options: ["Cold", "Hot"], icons: ["green_watch", "blue_watch"], nextQuestion: 999)
        
        questions += [q0, q1, q2, q3]
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
