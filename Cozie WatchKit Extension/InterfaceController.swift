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
    
    var currentCount = 0
    
    struct Question {
        let title: String
        let options: Array<String>
    }
    
    let tableData = ["one", "two"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let firtsQuestion = Question(title: "thermal sensation", options: ["yes", "no", "maybe"])
        let secondQuestion = Question(title: "thermal preference", options: ["yesss", "nooo", "maybeeee"])
        
        var questions: [Question] = []
        
        questions.append(firtsQuestion)
        questions.append(secondQuestion)
        
        print(questions[currentCount].title)
        
        loadTableData(question: &questions[currentCount])
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
        
        questionTitle.setText(question.title)

        tableView.setNumberOfRows(question.options.count, withRowType: "RowController")

        for (index, rowModel) in question.options.enumerated() {

            if let rowController = tableView.rowController(at: index) as? RowController {
                rowController.rowLabel.setText(rowModel)
            }
        }
        
        print("Current counter: \(currentCount)")
        
        print(currentCount)

    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        let firtsQuestion = Question(title: "thermal sensation", options: ["yes", "no", "maybe"])
        let secondQuestion = Question(title: "thermal preference", options: ["yesss", "nooo", "maybeeee"])
        
        var questions: [Question] = []
        
        questions.append(firtsQuestion)
        questions.append(secondQuestion)
        
        
        print("pressed button")
        print(questions[currentCount].options[rowIndex])
//        pushController(withName: "InterfaceController", context: tableData[rowIndex])

        // increment received number by one
        currentCount = currentCount + 1
        
        if (currentCount>1){
            currentCount = 0
        }
        
        loadTableData(question: &questions[currentCount])
    }
}
