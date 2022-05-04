////
////  TaskSurvey.swift
////  Cozie
////
////  Created by Federico Tartarini on 26/5/20.
////  Copyright © 2020 Federico Tartarini. All rights reserved.
////
//
//import Foundation
////import ResearchKit
//
//public var TaskOnBoarding: ORKOrderedTask {
//
//    var steps = [ORKStep]()
//
//    let instructionStep = ORKInstructionStep(identifier: "On-boarding")
//    instructionStep.title = "On-boarding survey"
//    instructionStep.text = "Please complete this survey before commencing collecting data."
//    steps += [instructionStep]
//
//    let heightQuestion = ORKQuestionStep(identifier: "heightQuestionStep",
//            title: "Your Height",
//            question: "How tall are  you",
//            answer: ORKHeightAnswerFormat(measurementSystem: .metric))
//    steps += [heightQuestion]
//
//    let happyQuestion = ORKQuestionStep(identifier: "Gender",
//            title: "Gender",
//            question: "What is your Gender",
//            answer: ORKTextChoiceAnswerFormat(style: .singleChoice,
//                    textChoices: [
//                        ORKTextChoice(text: "Male", value: NSNumber(integerLiteral: 0)),
//                        ORKTextChoice(text: "Female", value: NSNumber(integerLiteral: 1))]))
//    steps += [happyQuestion]
//
//    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
//    summaryStep.title = "Thank you!"
//    summaryStep.text = "That was easy!"
//    steps += [summaryStep]
//
//    return ORKOrderedTask(identifier: "On-boarding", steps: steps)
//}
