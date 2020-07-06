//
//  TaskSurvey.swift
//  Cozie
//
//  Created by Federico Tartarini on 26/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import ResearchKit

public var TaskSurvey: ORKOrderedTask {

    var steps = [ORKStep]()

    let instructionStep = ORKInstructionStep(identifier: "IntroStep")
    instructionStep.title = "The Questions Three"
    instructionStep.text = "Who would cross the Bridge of Death must answer me these questions three, ere the other side they see."
    steps += [instructionStep]

    let nameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
    nameAnswerFormat.multipleLines = false
    let nameQuestionStepTitle = "What is your name?"
    let nameQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nameQuestionStepTitle, answer: nameAnswerFormat)
    steps += [nameQuestionStep]


    let questQuestionStepTitle = "What is your quest?"
    let textChoices = [
        ORKTextChoice(text: "Create a ResearchKit App", value: 0 as NSNumber),
        ORKTextChoice(text: "Seek the Holy Grail", value: 1 as NSNumber),
        ORKTextChoice(text: "Find a shrubbery", value: 2 as NSNumber)
    ]
    let questAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
    let questQuestionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: questQuestionStepTitle, answer: questAnswerFormat)
    steps += [questQuestionStep]

    let colorQuestionStepTitle = "What is your favorite color?"
    let colorTuples = [
        (UIImage(named: "red")!, "Red"),
        (UIImage(named: "orange")!, "Orange"),
        (UIImage(named: "yellow")!, "Yellow"),
        (UIImage(named: "green")!, "Green"),
        (UIImage(named: "blue")!, "Blue"),
        (UIImage(named: "purple")!, "Purple")
    ]

    let imageChoices: [ORKImageChoice] = colorTuples.map {
        return ORKImageChoice(normalImage: $0.0, selectedImage: nil, text: $0.1, value: $0.1 as NSCoding & NSCopying & NSObjectProtocol)
    }
    let colorAnswerFormat: ORKImageChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoices)
    let colorQuestionStep = ORKQuestionStep(identifier: "ImageChoiceQuestionStep", title: colorQuestionStepTitle, answer: colorAnswerFormat)
    steps += [colorQuestionStep]

    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Right. Off you go!"
    summaryStep.text = "That was easy!"
    steps += [summaryStep]

    return ORKOrderedTask(identifier: "SurveyTask", steps: steps)
}
